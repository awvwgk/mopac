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

    Subroutine eigenvectors_LAPACK(eigenvecs, xmat, eigvals, ndim)
      USE chanel_C, only : iw
#ifdef GPU
      Use mod_vars_cuda, only: lgpu, ngpus, prec
#endif
#if (MAGMA)
      Use magma
      use initMagma
#endif

      implicit none
      Integer :: ndim
      double precision :: eigenvecs(ndim,ndim), &
                    & eigvals(ndim),xmat((ndim*(ndim+1))/2)
      integer :: i, j
      Integer :: lwork, liwork, info
      double precision,dimension(1:10) :: work_tmp
      Integer, dimension(1:10) :: iwork_tmp
      double precision, allocatable :: work(:)
      Integer, allocatable :: iwork(:)
!==============================================================================
! Code to find all eigenvectors and all eigenvalues for a symmetric General matrix
! using LAPACK and MAGMA
! Gerd Bruno Rocha and Julio Carvalho Maia 11/17/2013.
!==============================================================================
      continue
      eigvals = 0.d0
      eigenvecs = 0.d0

!
! Perturb secular determinant matrix to split exact degeneracies
! (This is to get around a bug in the diagonalizer that causes eigenvectors to not be orthonormal)
!
!  The following unusual construction works.  Do NOT change it unless degeneracy tests have been done,
!  and the results are reproducible.
!
      forall (i=1:ndim)
          xmat((i*(i + 1))/2) = xmat((i*(i + 1))/2) + i*1.d-10   ! Do NOT go much higher than 1.d-10, otherwise the geometry
      endforall                                              ! optimization might go into an endless loop.
      call dtpttr( 'u', ndim, xmat, eigenvecs, ndim, i )

#ifdef MKL
#ifdef GPU
if (lgpu .and. (ngpus > 1 .and. ndim > 100)) then
      call mkl_dimatcopy('C', 'T' , ndim, ndim, 1.0d0, eigenvecs, ndim, ndim)
end if
#endif
#endif
      if (i /= 0) stop 'error in dtpttr'

      j = i ! Dummy - to make FORCHECK not complain about "j"
      i = j ! Dummy
      if (i == -999) return
      lwork = -1
      liwork = -1

! GBR_new_addition

#if (MAGMA)
      if (lgpu .and. ndim > 100) then
         if (ngpus > 1) then
             call magma_dsyevd_Driver1(ngpus,'v','l',ndim,eigenvecs,ndim,eigvals,&
                    & work_tmp,lwork,iwork_tmp,liwork,info)
          else
             call magma_dsyevd_Driver1(ngpus,'v','u',ndim,eigenvecs,ndim,eigvals,&
                    & work_tmp,lwork,iwork_tmp,liwork,info)
          end if
      else
         call dsyevd('v','u',ndim,eigenvecs,ndim,eigvals,work_tmp,&
                    & lwork,iwork_tmp,liwork,info)
      end if
#else
      call dsyevd('v','u',ndim,eigenvecs,ndim,eigvals,work_tmp, &
                    & lwork,iwork_tmp,liwork,info)
#endif
      lwork = int(work_tmp(1))
      liwork = iwork_tmp(1)
      allocate (work(lwork), iwork(liwork), stat = i)
!      forall (j=1:lwork) work(j) = 0.d0
!      forall (j=1:liwork) iwork(j) = 0
#if (MAGMA)
      if (lgpu .and. ndim > 100) then
         if (ngpus > 1) then
             call magma_dsyevd_Driver2(ngpus,'v','l',ndim,eigenvecs,ndim,eigvals,&
                    & work,lwork,iwork,liwork,info)
          else
             call magma_dsyevd_Driver2(ngpus,'v','u',ndim,eigenvecs,ndim,eigvals,&
                    & work,lwork,iwork,liwork,info)
          end if
      else
         call dsyevd('v','u',ndim,eigenvecs,ndim,eigvals,work,&
                                & lwork,iwork,liwork,info)
      end if
#else

      call dsyevd('v','u',ndim,eigenvecs,ndim,eigvals,work, &
                                & lwork,iwork,liwork,info)
#endif

      deallocate (iwork,work,stat = j)
      if (info /= 0)  write(iw,*) ' dsyevd Diagonalization error., CODE =',info
      continue
      return
    End subroutine eigenvectors_LAPACK
