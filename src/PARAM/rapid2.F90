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

subroutine rapid2 (xparam, functn, grad, lgrad)
!
!
    use param_global_C, only : valvar, botlim, toplim, numvar, &
    power, nfns, diffns, fns, parab, factor, penalty
!
!
    implicit none
    double precision, dimension (numvar), intent (in) :: xparam
    double precision, intent (out) :: functn
    logical, intent (in) :: lgrad
    double precision, dimension (numvar) :: grad
!----------------------------------------------------------------

    integer :: i, j
    double precision :: curpar, error, sum
    intrinsic Max, Min
!----------------------------------------------------------------
!
!  Power is the power "n" in error = sum_i x_i**n
!  Default is 2, do NOT go less than about 1.05
!
    if (lgrad) then
      do i = 1, numvar
        grad(i) = 0.d0
      end do
    end if
  !
  !    CALCULATE THE ERROR
  !
    functn = 0.d0
    do i = 1, nfns
      sum = 0.d0
      do j = 1, numvar
        sum = sum + xparam(j) * diffns(j, i)
      end do
      error = (fns(i)-sum)*factor(i)
      if (lgrad) then
      !
      !   CALCULATE DERIVATIVES OF SSQ W.R.T. PARAMETERS
      !
        do j = 1, numvar
          grad(j) = grad(j) - &
          & factor(i)*Sign(1.d0,error)*Abs(error)**(power - 1.d0) * diffns(j, i) * power
        end do
      end if
    !
    !   CALCULATE FUNCTION = SSQ
    !
       functn = functn + abs(error)**power
    end do
  !
  !  Add a damping function - to avoid the effects of a very low
  !  eigenvalue in the parameter Hessian.
  !
    sum = 0.d0
    do i = 1, numvar
      functn = functn + xparam(i) ** 2 * parab
      if (lgrad) then
        grad(i) = grad(i) + 2 * xparam(i) * parab
 !       if (j == 1) then
 !       write(ifiles_8,'(5f12.6)')grad(j),factor(i),error,diffns(j,i)
 !       end if
      end if
    end do
  !
  ! Add a limiting function - to set "soft" upper and lower limits
  ! to the value of the functions
  !
    do i = 1, numvar
      curpar = valvar(i) - xparam(i)
      sum = (Max(0.d0, curpar-toplim(i))+Min(0.d0, curpar-botlim(i)))
      functn = functn + penalty * sum ** 2
      if (lgrad) then
        grad(i) = grad(i) - 2.d0 * penalty * sum
!        if (i == 1) then
!        write(ifiles_8,'(5f12.6)')grad(i)
!        end if
      end if
    end do
end subroutine rapid2
