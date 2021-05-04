      module rotate_C 
!
!   Set up an equivalence between the core-core array ccore and the individual
!   terms, for use in ROTATE 
!
      double precision :: css1, csp1, cpps1, cppp1, css2, csp2, cpps2, cppp2 
      double precision, dimension(4,2) :: ccore = 0.d0
      equivalence (ccore(1,1), css1), (ccore(2,1), csp1), (ccore(3,1), cpps1), &
      & (ccore(4,1), cppp1), (ccore(1,2), css2), (ccore(2,2), csp2), &
      & (ccore(3,2), cpps2), (ccore(4,2), cppp2)
      end module rotate_C 