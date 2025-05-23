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

subroutine mlmo (locc, lvir, ii, jj, nf_loc, ne, nocc, nvir, iz, ib, nce, &
     & ncf, ncocc, ncvir, iorbs, icocc, icvir, cocc, cvir)
    use molkst_C, only: numat, norbs
    use MOZYME_C, only : icocc_dim, icvir_dim, cocc_dim, &
         & cvir_dim, ipad2, ipad4
    implicit none
    integer, intent (in) :: ii, jj
    integer, intent (inout) :: locc, lvir, ne, nf_loc, nocc, nvir
    integer, dimension (*), intent (inout) :: ncf, ncocc
    integer, dimension (*), intent (inout) :: nce, ncvir
    integer, dimension (numat), intent (in) :: iorbs
    integer, dimension (numat), intent (inout) :: ib, iz
    integer, dimension (icocc_dim), intent (inout) :: icocc
    integer, dimension (icvir_dim), intent (inout) :: icvir
    double precision, dimension (cocc_dim), intent (inout) :: cocc
    double precision, dimension (cvir_dim), intent (inout) :: cvir
!
    integer :: i, iocc, ivir, j, k, nes, nfs
    nes = ne
    nfs = nf_loc
    iocc = locc
    ivir = lvir
    if (ii /= 0) then
      !
      !   OCCUPIED M.O.
      !
      iz(ii) = iz(ii) - 1
      if (jj == 0) then
        iz(ii) = iz(ii) - 1
      end if
      ib(ii) = ib(ii) - 1
      nocc = nocc + 1
      ncocc(nocc) = locc
      locc = locc + iorbs(ii)
      nf_loc = nf_loc + 1
      icocc(nf_loc) = ii
      ncf(nocc) = 1
    end if
    if (jj /= 0) then
      !
      !   VIRTUAL M.O.
      !
      iz(jj) = iz(jj) - 1
      if (ii == 0) then
        iz(jj) = iz(jj) + 1
      end if
      ib(jj) = ib(jj) - 1
      nvir = nvir + 1
      ncvir(nvir) = lvir
      lvir = lvir + iorbs(jj)
      ne = ne + 1
      nce(nvir) = 1
      if (ii /= 0) then
        icvir(ne) = ii
        ncf(nocc) = 2
        nce(nvir) = 2
      else
        icvir(ne) = jj
      end if
    end if
    if (ii /= 0 .and. jj /= 0) then
      !
      !   OCCUPIED AND VIRTUAL M.O.
      !
      nf_loc = nf_loc + 1
      icocc(nf_loc) = jj
      ne = ne + 1
      icvir(ne) = jj
      locc = locc + iorbs(jj)
      lvir = lvir + iorbs(ii)
    end if
   !
   !  Assign space for LMO's to expand into.
   !  J = SPACE RESERVED FOR ATOM INDICES IN ICOCC AND/OR ICVIR
   !  K = SPACE RESERVED FOR ATOMIC ORBITALS IN COCC AND/OR CVIR
   !
    j = Min (numat*2, ipad2)
    k = Min (norbs*2, ipad4)
    if (ii /= 0) then
      nf_loc = nfs + j
      do i = locc + 1, iocc + k
        cocc(i) = 0.d0
      end do
      locc = iocc + k
    end if
    if (jj /= 0) then
      ne = nes + j
      do i = lvir + 1, ivir + k
        cvir(i) = 0.d0
      end do
      lvir = ivir + k
    end if
end subroutine mlmo
