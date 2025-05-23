! Molecular Orbital PACkage (MOPAC)
! Copyright 2021 Virginia Polytechnic Institute and State University
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!    http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.

subroutine modgra ()
   !***********************************************************************
   !
   !   MODGRA prints the gradients due to (a) backbone residue atoms, and
   !   (b) all side-chain atoms in each residue.
   !
   !***********************************************************************
    use molkst_C, only: numat, nvar, maxtxt, natoms
    use chanel_C, only: iw
    use common_arrays_C, only : grad, loc, txtatm
    use MOZYME_C, only : nres, at_res, res_start
    implicit none
    double precision, allocatable :: rgrad(:), res_grad_b(:), res_grad_s(:)
    double precision :: sum
    integer :: i, j
    logical :: L_protein
    allocate(rgrad(natoms), res_grad_b(natoms), res_grad_s(natoms))
    call build_res_start_etc()
!
!  Put atomic gradients into an atom-based array
!
    rgrad      = 0.d0
    res_grad_b = 0.d0
    res_grad_s = 0.d0
    do i = 1, nvar
      j = loc(1, i)
      rgrad(j) = rgrad(j) + grad(i) ** 2
    end do
    l_protein = .false.
    do i = 1, numat
      j = at_res(i)
      if (txtatm(i)(:6) == "ATOM  " .and. &
      (txtatm(i)(13:15) == " CA" .or. txtatm(i)(13:15) == " N " .or. txtatm(i)(13:15) == " C ")) then
        res_grad_b(j) = res_grad_b(j) + rgrad(i)
        l_protein = .true.
      else
        res_grad_s(j) = res_grad_s(j) + rgrad(i)
      end if
    end do
    sum = 0.d0
    do i = 1, nres
      res_grad_b(i) = sqrt(res_grad_b(i))
      res_grad_s(i) = sqrt(res_grad_s(i))
      sum = sum + res_grad_b(i) + res_grad_s(i)
    end do
    if (l_protein) then
      if (sum < 0.5d0) then
        write (iw,"(/12x,a,/)") " ALL GRADIENTS FOR ALL BACKBONES PLUS SIDE CHAINS ARE VERY SMALL"
      else
        write (iw,"(/12x,a,/)") " GRADIENTS FOR ALL BACKBONES"
        write (iw,"(a)")"     Residue        Backbone    Side-Chain        Total"
        write(iw,*)
        do i = 1, nres
          if (txtatm(res_start(i))(18:20) /= "HOH" .or. abs(res_grad_s(i)) > 1.d0) &
            write(iw,'(4x, a, f15.3, f12.3, f15.3)')txtatm(res_start(i))(18:maxtxt), &
            res_grad_b(i), res_grad_s(i), res_grad_b(i) + res_grad_s(i)
          end do
      end if
    else
      if (sum < 0.5d0) then
        write (iw,"(/12x,a,/)") " ALL GRADIENTS FOR ALL GROUPS ARE VERY SMALL"
      else
        write (iw,"(/13x,a,/)") " GRADIENTS FOR ALL GROUPS"
        write (iw,"(11x,a)")"     Group       Gradient"
        write(iw,*)
        write(iw,'(14x, a, f13.3)')(txtatm(res_start(i))(18:20)//" "//txtatm(res_start(i))(23:26),  &
          res_grad_s(i),i = 1, nres)
      end if
    end if
    return
end subroutine modgra
