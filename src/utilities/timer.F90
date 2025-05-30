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

      subroutine timer(a)
!
!  Write out CPU and wall-clock times for the current step, and total times
!
      Use molkst_C, only : wall_clock_0, wall_clock_1, CPU_1, CPU_0
      USE chanel_C, only : iw
      implicit none
      character , intent(in) :: a*(*)
      character :: b*20
      double precision :: CPU_start, CPU_last, CPU_now
      real :: wall_clock_last, dummy
      logical :: first
      double precision, external :: seconds
      save first, CPU_start, CPU_last, wall_clock_last
      data first/ .TRUE./
      if (first) then
!
!  DEFINE THE ZERO OF TIME
!
        CPU_start = seconds(1)
        CPU_start = CPU_0
        CPU_last = CPU_start
        wall_clock_last = wall_clock_1
        wall_clock_0 = wall_clock_last
        first = .FALSE.
      end if
!
! "dummy" call: wall_clock_1 is set in seconds(1), but call needed to set CPU_1
!
      dummy = real(seconds(1))
      if (dummy < -300.0) return
      CPU_now = CPU_1
      b = a
      write (iw, '(2x, a20, a, f7.2,  a, f11.2, a, f7.2, a, f9.2)') b, 'CPU INTERVAL:', &
      CPU_now - CPU_last, ', INTEGRAL:', CPU_now - CPU_start, &
      '    WALL-CLOCK INTERVAL:', wall_clock_1 - wall_clock_last, ', INTEGRAL:', &
      wall_clock_1 - wall_clock_0
      CPU_last = CPU_now
      wall_clock_last = wall_clock_1
      return
      end subroutine timer
