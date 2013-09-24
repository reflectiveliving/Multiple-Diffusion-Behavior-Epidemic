extensions [array]

globals [
  costs  ;; costs of each of the behaviors
  utilities ;; intrinsic benefits from each of the behaviors
  behav-id-list ;; list of behavior ids
  all-zeros ;; a list of length num-behaviors containing zeros

  roundActiveCounts  ;; stores the number of agents who turned active in the previous round for each behavior
  
  total-active-count ;; total number of active agents
  total-unique-active-count ;; total number of unique active agents
  active-counts ;; holds number of active agents per behavior
  old-active-counts ;; temp variable for calculating roundActiveCount
  total-resource ;; total resource available to the agents after seed selection
  utilization ;; network wide resource utilization
  
  num-seeds-per-behavior ;; vector for storing number of seeds per behavior
  
  ;; coloring variables ;;
  neutral
  base
  step
  scaling
  
  ;;stores the seed sets for go-bspace
  seed-sets
  
  ;; go-bspace statistics
  total-part-mean
  total-part-sd
  total-adopt-mean
  total-adopt-sd
  act-counts-mean
  act-counts-sd
  util-mean
  util-sd
]

turtles-own
[
  resource   ;; total resource available to this agent for behavior adoption 
  resource-backup ;; backs up the resource value of each agent while running the spread based seedselection simulations
  thresholds ;; thresholds of adoption for each possible behavior
  actives?   ;; whether this agent is active or not for the particular behavior
  weight-sums ;; used to sum up influence weight from active neighbors
  payoffs    ;; payoff from each of the the behaviors
  consider?  ;; boolean array for indicating whether a behavior will be considered for adoption or not
  ;; turtle variable required for seed selection algorithms
  one-step-spreads ;; vector containing the expected one-step adoption of the turtle
  spreads ;; vectors containing the spread for each behavior of this node
]

links-own
[
  end1-weight ;; influence weight exerted by the end2 on end1
  end2-weight ;; vice versa
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  
  ;; create the small example network
  
  ;set-default-shape turtles "person"
  
  set-coloring-variables
  
  random-seed 12345 + rand-seed-network
  setup-small-world-network
  
  set-behaviors
  
  set-edge-weights
  
  random-seed 123456 + rand-seed-resource
  set-resource
  
  random-seed 1234567 + rand-seed-threshold
  set-thresholds
  
  set-actives
  set-weight-sums
  set-payoffs
  set-consider 
  
  random-seed 12345 + rand-seed-network
  select-seeds
  
  setup-indicators
  
  reset-ticks
end

to set-coloring-variables
  set neutral white
  set base red
  set step 10
  set scaling (base + num-behaviors * step) - (base + base + step)
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Small World Network;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-small-world-network
  make-turtles
  wire-them
  rewire-all
end

to make-turtles
  set-default-shape turtles "person"
  crt number-of-nodes [ 
    set color neutral 
    set size 1.5
  ]
  ;; arrange them in a circle in order by who number
  ;layout-circle (sort turtles) max-pxcor - 1
end

to wire-them
  ;; iterate over the turtles
  let n 0
  while [n < count turtles]
  [
    ;; make edges with the next two neighbors
    ;; this makes a lattice with average degree of 4
    make-edge turtle n
              turtle ((n + 1) mod count turtles)
    make-edge turtle n
              turtle ((n + 2) mod count turtles)
    set n n + 1
  ]
end

;; connects the two turtles
to make-edge [node1 node2]
  ask node1 [ create-link-with node2  
    ;[
    ;  set color neutral - 2
    ;] 
  ]
end

to rewire-all

  ;; make sure num-turtles is setup correctly; if not run setup first
  if count turtles != number-of-nodes [
    setup-small-world-network
  ]
  
  ask links [

    let rewired? false
    ;; whether to rewire it or not?
    if (random-float 1) < rewiring-probability
    [
      ;; "a" remains the same
      let node1 end1
      ;; if "a" is not connected to everybody
      if [ count link-neighbors ] of end1 < (count turtles - 1)
      [
        ;; find a node distinct from node1 and not already a neighbor of node1
        let node2 one-of turtles with [ (self != node1) and (not link-neighbor? node1) ]
        ;; wire the new edge
        ask node1 [ create-link-with node2 
          ;[ 
          ;  set color neutral - 2
          ;] 
        ]

        set rewired? true
      ]
    ]
    ;; remove the old edge
    if (rewired?)
    [
      die
    ]
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;
;;;Parameterization;;;;
;;;;;;;;;;;;;;;;;;;;;;;

to set-behaviors
  ;set costs array:from-list n-values num-behaviors [random-float 1]
  ;set utilities array:from-list n-values num-behaviors [random-float 1]
  
  set costs read-from-string behavior-costs
  ifelse is-list? costs [
    set costs array:from-list costs
  ]
  [
    user-message "Input behaivor costs as a list i.e. within []"
    stop
  ]
  
  set utilities read-from-string behavior-utilities
  ifelse is-list? utilities [
    set utilities array:from-list utilities
  ]
  [
    user-message "Input behavior utilities as a list i.e. within []"
    stop
  ]
  
  set behav-id-list n-values num-behaviors [?]
  set all-zeros n-values num-behaviors [0]
end

;; sets edge weights such that sum of incoming edge weights equal to 1,
;; and each incoming edge for an agent has same weight
to set-edge-weights
  ask turtles [
    if count my-links != 0 [
      let weight 1.0 / count my-links
      ask my-links [
        set-weight myself weight
      ]
    ]
  ]
end

;; link procedure
to set-weight [node weight]
  ifelse end1 = node [
    set end1-weight weight
  ]
  [
    set end2-weight weight
  ]
end 

;; set individual resources for each agent
to set-resource
  ask turtles [
    set resource random-float 1
  ]
end

;; set individual active states for each agent
to set-actives
  ask turtles [
    set actives? array:from-list n-values num-behaviors [false]
  ]
end
   
;; set agent thresholds before every run 
to set-thresholds 
  ifelse matched-threshold? [
    ask turtles [
      let thresh random-float 1
      set thresholds array:from-list n-values num-behaviors [thresh]
    ]
  ]
  [   
    ask turtles [
      set thresholds  array:from-list n-values num-behaviors [random-float 1]
    ]
  ]
end

; set weight-sum for the behaviors to zero
to set-weight-sums
  ask turtles [
    set weight-sums array:from-list all-zeros
  ]
end

; set agent payoffs for all the behaviors
to set-payoffs
  ask turtles [
    set payoffs array:from-list all-zeros
  ]
end

; set the consider? boolean array
to set-consider
  ask turtles [
    set consider? array:from-list n-values num-behaviors [false]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;
;;;Seed Selection;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;

to select-seeds 
  
  ;; Determine the seed distribution i.e. number of seeds per behavior
  ifelse seed-distribution = "uniform" [
    set-uniform-seed-distribution
  ][
  ifelse seed-distribution ="proportional to cost" [
    set-proportional-to-cost-seed-distribution
  ][
  ifelse seed-distribution = "inversely proportional to cost" [
    set-inversely-proportional-to-cost-seed-distribution
  ][
  ifelse seed-distribution = "highest cost behavior only" [
    set-highest-cost-behavior-only
  ][
  ifelse seed-distribution = "lowest cost behavior only" [
    set-lowest-cost-behavior-only
  ][
  ifelse seed-distribution = "in ratio" [
    set-in-ratio
  ][
  user-message "Specify the seed distribution"
  ]]]]]]
  
  ;; select seeds
  ifelse seed-selection-algorithm = "randomly-unlimited-seed-resource-batched" [
    randomly-unlimited-seed-resource-batched
  ][
  ifelse seed-selection-algorithm = "randomly-unlimited-seed-resource-incremental" [
    randomly-unlimited-seed-resource-incremental
  ][
  ifelse seed-selection-algorithm = "randomly-with-available-resource-batched" [
    randomly-with-available-resource-batched
  ][
  ifelse seed-selection-algorithm = "randomly-with-available-resource-incremental" [
    randomly-with-available-resource-incremental
  ][
  ifelse seed-selection-algorithm = "randomly-with-knapsack-assignment" [
    randomly-with-knapsack-assignment
  ][
  ifelse seed-selection-algorithm = "randomly-with-random-tie-breaking"[
    randomly-with-random-tie-breaking
  ][
  ifelse seed-selection-algorithm = "naive-degree-ranked-with-knapsack-assignment" [
    naive-degree-ranked-with-knapsack-assignment
  ][
  ifelse seed-selection-algorithm = "naive-degree-ranked-with-random-tie-breaking-no-nudging" [
    naive-degree-ranked-with-random-tie-breaking-no-nudging
  ][
  ifelse seed-selection-algorithm = "naive-degree-ranked-with-random-tie-breaking-with-nudging" [
    naive-degree-ranked-with-random-tie-breaking-with-nudging
  ][
  ifelse seed-selection-algorithm = "degree-and-resource-ranked-with-knapsack-tie-breaking" [
    degree-and-resource-ranked-with-knapsack-tie-breaking
  ][
  ifelse seed-selection-algorithm = "degree-and-resource-ranked-with-random-tie-breaking" [
    degree-and-resource-ranked-with-random-tie-breaking
  ][
  ifelse seed-selection-algorithm = "one-step-spread-ranked-with-random-tie-breaking" [
    one-step-spread-ranked-with-random-tie-breaking
  ][
  ifelse seed-selection-algorithm = "one-step-spread-hill-climbing-with-random-tie-breaking" [
    one-step-spread-hill-climbing-with-random-tie-breaking
  ][
  ifelse seed-selection-algorithm = "spread-based-hill-climbing-with-random-tie-breaking" [
    spread-based-hill-climbing-with-random-tie-breaking
  ][
  ifelse seed-selection-algorithm = "ideal-all-agent-adoption-without-network-effect" [
    ideal-all-agent-adoption-without-network-effect
  ][
  user-message "Specify the seed selection algorithm"
  ]]]]]]]]]]]]]]]
end

;;;;;;;;;;;;;;;;;;;;;;;
;;;Seed distribution;;;
;;;;;;;;;;;;;;;;;;;;;;;

to set-uniform-seed-distribution  
  let seeds-per-behavior (round  (total-num-seeds / num-behaviors))
  
  set num-seeds-per-behavior array:from-list n-values num-behaviors [seeds-per-behavior]
end

to set-proportional-to-cost-seed-distribution
  set num-seeds-per-behavior array:from-list all-zeros
  
  let sum-behav-costs sum array:to-list costs
  
  foreach behav-id-list [
    array:set num-seeds-per-behavior ? (round ((array:item costs ?) / sum-behav-costs * total-num-seeds)) 
  ]
end

to set-inversely-proportional-to-cost-seed-distribution
  set num-seeds-per-behavior array:from-list all-zeros
  
  let sorted-behaviors sort-by sort-by-cost (behav-id-list)
  
  let sum-behav-costs sum array:to-list costs
  
  foreach behav-id-list [
    array:set num-seeds-per-behavior (item ? sorted-behaviors) (round ((array:item costs (item (num-behaviors - 1 - ?) sorted-behaviors)) / sum-behav-costs * total-num-seeds))
  ]
end

to set-highest-cost-behavior-only
  set num-seeds-per-behavior array:from-list all-zeros
  let sorted-behaviors sort-by sort-by-cost (behav-id-list)
  
  array:set num-seeds-per-behavior (first sorted-behaviors) total-num-seeds
end

to set-lowest-cost-behavior-only
  set num-seeds-per-behavior array:from-list all-zeros
  let sorted-behaviors sort-by sort-by-cost (behav-id-list)
  
  array:set num-seeds-per-behavior (last sorted-behaviors) total-num-seeds
end  

to-report sort-by-cost [first-behav-id second-behav-id]
  report array:item costs first-behav-id > array:item costs second-behav-id
end

to set-in-ratio
  set num-seeds-per-behavior array:from-list all-zeros
  let ratio read-from-string final-ratio
  let sum-ratio sum ratio
  foreach behav-id-list [
    array:set num-seeds-per-behavior ? (round ((item ? ratio) / sum-ratio * total-num-seeds))
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Maximum Utilization Computation;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to ideal-all-agent-adoption-without-network-effect
  ask turtles [
        foreach behav-id-list [
          array:set consider? ? true
          array:set payoffs ? array:item utilities ?
        ]
        
        let opt knapsack-decide
        
        foreach opt [
          array:set actives? ? true
        ]
        
        if not empty? opt [
          set-color
        ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Random Seed Selection;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; selects seeds uniformly at random from the set of all agents
;; increase resource if necessary (unlimited resource of seed nodes), seeds selected in batches
to randomly-unlimited-seed-resource-batched
  foreach behav-id-list [
    let seeds n-of array:item num-seeds-per-behavior ? turtles
    ask seeds [
      let used used-resource
      if used + array:item costs ? > resource [
        set resource (used + array:item costs ?)
      ]
      ; set resource 1.0
      array:set actives? ? true
      set-color
    ]
  ]
end

;; same as the previous one but seeds selected one at a time
to randomly-unlimited-seed-resource-incremental
;  repeat number-of-seeds-per-behavior [
;     foreach behav-id-list [
;       ask one-of turtles with [array:item actives? ? = false] [force-adopt ?]
;     ]
;  ]
end

;; turtle procedure
to force-adopt [behav-id] 
  let used used-resource
  if used + array:item costs behav-id > resource [
    set resource (used + array:item costs behav-id)
  ]
  array:set actives? behav-id true
  set-color
end

;; seeds randomly selected from the nodes with available resource
;; ordering of the given behaviors matter
to randomly-with-available-resource-batched
  foreach behav-id-list [
    let pop turtles with [(resource - used-resource) >= array:item costs ?]
    let seeds nobody 
    ifelse array:item num-seeds-per-behavior ? > count pop [
      set seeds pop
    ]
    [
      set seeds n-of array:item num-seeds-per-behavior ? pop
    ]
      
    ask seeds [
      array:set actives? ? true
      set-color
    ]
  ]
end

to randomly-with-available-resource-incremental
;  repeat number-of-seeds-per-behavior [
;     foreach behav-id-list [
;       let seed one-of turtles with [((resource - used-resource) >= array:item costs ?) and (array:item actives? ? = false)]
;       if seed != nobody [
;         ask seed [
;           array:set actives? ? true
;           set-color
;         ]
;       ]
;     ]
;  ]
end
  
to randomly-with-knapsack-assignment
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  while [more-seeds-required? seeds-required] [
    let candidate-seed one-of pop
    ifelse candidate-seed = nobody [
      stop
    ]
    [ 
      ask candidate-seed [
        set pop other pop  
        
        foreach behav-id-list [
          if array:item seeds-required ? > 0 [
            array:set consider? ? true
            array:set payoffs ? (array:item utilities ?)
          ]
        ]
        
        let opt knapsack-decide
        
        foreach behav-id-list [
          array:set consider? ? false
          array:set payoffs ? 0
        ]
        
        foreach opt [
          array:set actives? ? true
          array:set seeds-required ? (array:item seeds-required ? - 1)
        ]
        
        if not empty? opt [
          set-color
        ]
      ]
    ]
  ]
end 

to-report more-seeds-required? [seeds-required]
  foreach behav-id-list [
    if array:item seeds-required ? > 0 [
      report true
    ]
  ]
  report false
end   
           
        
;; turtle procedure to report total used resouces by the already
;; adopted behaviors        
to-report used-resource
  let used 0
  foreach behav-id-list [
    if array:item actives? ? [
      set used used + array:item costs ?
    ]
  ]
  report used
end

to randomly-with-random-tie-breaking
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  
  while [more-seeds-required? seeds-required] [
    let seedsets map [n-of (array:item seeds-required ?) pop] (behav-id-list)
    
    let seeds reduce [(turtle-set ?1 ?2)] seedsets
    
    set pop pop with [not member? self seeds]
    
    ask seeds [
      let candidates filter [member? self (item ? seedsets)] (behav-id-list)
      let winner item (random length candidates) candidates
      array:set actives? winner true
      array:set seeds-required winner ((array:item seeds-required winner) - 1)
      ;; with resource nudging
      if array:item costs winner > resource [
        set resource array:item costs winner
      ]
      set-color
    ] 
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Degree Centrality Based;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to naive-degree-ranked-with-knapsack-assignment
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  while [more-seeds-required? seeds-required] [
    let candidate-seed max-one-of pop [count link-neighbors]
    ifelse candidate-seed = nobody [
      stop
    ]
    [ 
      ask candidate-seed [
        set pop other pop  
        
        foreach behav-id-list [
          if array:item seeds-required ? > 0 [
            array:set consider? ? true
            array:set payoffs ? (array:item utilities ?)
          ]
        ]
        
        let opt knapsack-decide
        
        foreach behav-id-list [
          array:set consider? ? false
          array:set payoffs ? 0
        ]
        
        foreach opt [
          array:set actives? ? true
          array:set seeds-required ? (array:item seeds-required ? - 1)
        ]
        
        if not empty? opt [
          set-color
        ]
      ]
    ]
  ]
end

to naive-degree-ranked-with-random-tie-breaking-no-nudging
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  while [more-seeds-required? seeds-required] [
    let candidate-seed max-one-of pop [count link-neighbors]
    ifelse candidate-seed = nobody [
      stop
    ]
    [
      ask candidate-seed [
        set pop other pop
        let candidate-behavs filter [array:item seeds-required ? != 0] behav-id-list 
        let winner item (random length candidate-behavs) candidate-behavs
        if array:item costs winner <= resource [
          array:set actives? winner true
          array:set seeds-required winner ((array:item seeds-required winner) - 1)
          set-color
        ]
      ]
    ]
  ]
end

to naive-degree-ranked-with-random-tie-breaking-with-nudging
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  while [more-seeds-required? seeds-required] [
    let candidate-seed max-one-of pop [count link-neighbors]
    ifelse candidate-seed = nobody [
      stop
    ]
    [
      ask candidate-seed [
        set pop other pop
        let candidate-behavs filter [array:item seeds-required ? != 0] behav-id-list 
        let winner item (random length candidate-behavs) candidate-behavs
        array:set actives? winner true
        array:set seeds-required winner ((array:item seeds-required winner) - 1)
        ;; with resource nudging
        if array:item costs winner > resource [
          set resource array:item costs winner
        ]
        set-color
      ]
    ]
  ]
end

to degree-and-resource-ranked-with-knapsack-tie-breaking
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pops array:from-list n-values num-behaviors [turtles]
  while [continue-seed-selection? seeds-required] [
    let seedsets []
    foreach behav-id-list [
      let num-required-seeds ((array:item seeds-required ?) - (count turtles with [array:item actives? ?]))
      let seedset nobody
      ifelse num-required-seeds > count array:item pops ? [
        set seedset array:item pops ?
        array:set seeds-required ? 0 ;; to set continue-seed-selection? false
      ][
      ifelse num-required-seeds >= 0 [
        set seedset max-n-of num-required-seeds (array:item pops ?) [count link-neighbors with [resource >= (array:item costs ?)]]
      ][
      set seedset turtle-set nobody
      ]]
      set seedsets sentence seedsets seedset
      array:set pops ? ((array:item pops ?) with [not member? self seedset])
    ]
    
    let seeds turtle-set nobody
    foreach seedsets [
      set seeds (turtle-set seeds ?)
    ]
    
    ask seeds [
      foreach behav-id-list [
        if (member? self (item ? seedsets)) or array:item actives? ? [
          array:set consider? ? true
          array:set payoffs ? (array:item utilities ?)
        ]
      ]
      
      let opt knapsack-decide

      foreach behav-id-list [
        array:set consider? ? false
        array:set payoffs ? 0
      ]
      
      foreach behav-id-list [
        array:set actives? ? false
      ]
      
      foreach opt [
        array:set actives? ? true
      ]
      
      if not empty? opt [
        set-color
      ]
    ]      
  ]
end  

to-report continue-seed-selection? [seeds-required]
  foreach behav-id-list [
    if (array:item seeds-required ?) - (count turtles with [array:item actives? ?]) > 0 [
      report true
    ]
  ]
  report false
end

to degree-and-resource-ranked-with-random-tie-breaking
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  
  while [more-seeds-required? seeds-required] [
    let seedsets map [max-n-of (array:item seeds-required ?) pop [count link-neighbors with [resource >= array:item costs ?]]] (behav-id-list)
    
    let seeds reduce [(turtle-set ?1 ?2)] seedsets
    
    set pop pop with [not member? self seeds]
    
    ask seeds [
      let candidates filter [member? self (item ? seedsets)] (behav-id-list)
      let winner item (random length candidates) candidates
      array:set actives? winner true
      array:set seeds-required winner ((array:item seeds-required winner) - 1)
      ;; with resource nudging
      if array:item costs winner > resource [
        set resource array:item costs winner
      ]
      set-color
    ] 
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Expected one step adoption;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; one step spread is the expected adoption in one time step
to one-step-spread-ranked-with-random-tie-breaking
  calculate-expected-one-step-adoption
  
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  
  while [more-seeds-required? seeds-required] [
    ;let seedsets map [max-n-of (array:item seeds-required ?) (pop with [resource >= array:item costs ?]) [array:item one-step-spreads ?]] (behav-id-list)
    ;; with resource nudging
    let seedsets map [max-n-of (array:item seeds-required ?) pop [array:item one-step-spreads ?]] (behav-id-list) 
    
    let seeds reduce [(turtle-set ?1 ?2)] seedsets
    
    set pop pop with [not member? self seeds]
    
    ask seeds [
      let candidates filter [member? self (item ? seedsets)] (behav-id-list)
      let winner item (random length candidates) candidates
      array:set actives? winner true
      array:set seeds-required winner ((array:item seeds-required winner) - 1)
      ;; with resource nudging
      if array:item costs winner > resource [
        set resource array:item costs winner
      ]
      set-color
    ] 
  ] 
end

to one-step-spread-hill-climbing-with-random-tie-breaking
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  let seedsets array:from-list n-values num-behaviors [turtle-set nobody]
  
   while [more-seeds-required? seeds-required] [
     let new-seedsets map [compute-optimal-seedset-one-step-spread ? (array:item seeds-required ?) (array:item seedsets ?) pop] (behav-id-list) 
     
     foreach behav-id-list [
       if array:item seeds-required ? > count (item ? new-seedsets) [
         array:set seeds-required ? 0
       ]
     ]
     
     let new-seeds reduce [(turtle-set ?1 ?2)] new-seedsets
     
     set pop pop with [not member? self new-seeds]
     
     ask new-seeds [
      let candidates filter [member? self (item ? new-seedsets)] (behav-id-list)
      let winner item (random length candidates) candidates
      array:set actives? winner true
      array:set seeds-required winner ((array:item seeds-required winner) - 1)
      array:set seedsets winner (turtle-set array:item seedsets winner self)
      ;; with resource nudging
      if array:item costs winner > resource [
        set resource array:item costs winner
      ]
      set-color
    ]   
   ]  
end

to-report compute-optimal-seedset-one-step-spread [b-id num-seeds seedset remaining-pop]
  let pop turtles with [not member? self seedset]
  
  let new-seedset (turtle-set nobody)
  
  repeat num-seeds [
    ;; additional one-step adoption calculation
    init-one-step-spreads
    ask pop [
      let num-neighbors (count link-neighbors)
      let prob 0
      if (num-neighbors != 0) [
        set prob 1 / num-neighbors
      ]
      if [resource] of self >= array:item costs b-id [
        ask link-neighbors [
          array:set one-step-spreads b-id ((array:item one-step-spreads b-id) + prob)
        ]
      ]
    ]
    
    let newseed max-one-of remaining-pop [array:item one-step-spreads b-id]
    set new-seedset (turtle-set new-seedset newseed)
    ifelse newseed = nobody [
      report new-seedset
    ]
    [
      ask newseed [
        set pop other pop
        set remaining-pop other remaining-pop
      ]
    ]
  ]
  
  report new-seedset       
end

to calculate-expected-one-step-adoption
  init-one-step-spreads
  
  ask turtles [
    let num-neighbors (count link-neighbors)
    let prob 0
    if (num-neighbors != 0) [
      set prob 1 / num-neighbors
    ]
    ask link-neighbors [
      foreach behav-id-list [
        if [resource] of myself >= array:item costs ? [
          array:set one-step-spreads ? ((array:item one-step-spreads ?) + prob)
        ]
      ]
    ]
  ]
end

to init-one-step-spreads
  ask turtles [
    set one-step-spreads array:from-list all-zeros
  ]
end

to reset-one-step-spreads
  ask turtles [
    foreach behav-id-list [
      array:set one-step-spreads ? 0
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Spread Based Hill Climbing;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to spread-based-hill-climbing-with-random-tie-breaking
  init-spreads
  backup-resource
  let seeds-required array:from-list array:to-list num-seeds-per-behavior
  let pop turtles
  let seedsets array:from-list n-values num-behaviors [turtle-set nobody]
  
   while [more-seeds-required? seeds-required] [
     let new-seedsets map [compute-greedy-spread-based-seedset ? (array:item seeds-required ?) (array:item seedsets ?) pop] (behav-id-list) 
     
     foreach behav-id-list [
       if array:item seeds-required ? > count (item ? new-seedsets) [
         array:set seeds-required ? 0
       ]
     ]
     
     let new-seeds reduce [(turtle-set ?1 ?2)] new-seedsets
     
     set pop pop with [not member? self new-seeds]
     
     ask new-seeds [
      let candidates filter [member? self (item ? new-seedsets)] (behav-id-list)
      let winner item (random length candidates) candidates
      ;array:set actives? winner true
      array:set seeds-required winner ((array:item seeds-required winner) - 1)
      array:set seedsets winner (turtle-set array:item seedsets winner self)
      ;; with resource nudging ; Consider doing the top up here vs in set-seeds-active
      ;if array:item costs winner > resource [
       ; set resource array:item costs winner
      ;]
      ;set-color
    ]   
   ] 
   
  ;; actives? field, color and resource is messed-up so set it up again
  set-actives
  set-neutral-color
  restore-resource
  
  set seed-sets seedsets
  set-seeds-active seedsets
  
end  

to init-spreads
  ask turtles [
    set spreads array:from-list all-zeros
  ]
end

to backup-resource
  ask turtles [
    set resource-backup resource
  ]
end

to restore-resource
  ask turtles [
    set resource resource-backup
  ]
end

to set-neutral-color
  ask turtles [
    set color neutral
  ]
end

to set-seeds-active [seedsets]
  (foreach behav-id-list array:to-list seedsets [
      ask ?2 [
        array:set actives? ?1 true
        set-color
        if array:item costs ?1 > resource [
          set resource array:item costs ?1
        ]
      ]
  ])
end

to-report compute-greedy-spread-based-seedset [b-id num-seeds seedset remaining-pop]
  let pop remaining-pop
  
  let new-seedset (turtle-set nobody)
  
  repeat num-seeds [
    compute-spread-for-pop b-id pop (turtle-set seedset new-seedset)   
    let newseed max-one-of pop [array:item spreads b-id]
    set new-seedset (turtle-set new-seedset newseed)
    ifelse newseed = nobody [
      report new-seedset
    ]
    [
      ask newseed [
        set pop other pop
      ]
    ]
  ]
  
  report new-seedset    
end

to compute-spread-for-pop [b-id pop seedset]
  foreach sort pop [
    let spread-est estimate-spread b-id (turtle-set seedset ?)
    ask ? [
      array:set spreads b-id spread-est  
    ]
  ]
end

to-report estimate-spread [b-id seedset]
  let rand-seed 4567
  let spread-est 0
  ;let num-sim-for-spread-based-seed-selection 50

  repeat num-sim-for-spread-based-seed-selection [
    set spread-est spread-est + simulate-model b-id seedset rand-seed
    set rand-seed rand-seed + 1
  ]
  report spread-est / num-sim-for-spread-based-seed-selection
end

to-report simulate-model [b-id seedset rand-seed]
  mini-setup b-id seedset rand-seed
  ;let max-step 100
  let step-count 0
  while [(not no-new-adoption?) and (step-count < max-step)] [
    mini-go
    set step-count step-count + 1
  ] 
  report count turtles with [array:item actives? b-id]
end

to mini-setup [b-id seedset rand-seed]
  set-actives
  set-neutral-color
  restore-resource
  set-active b-id seedset
  random-seed 1234567 + rand-seed
  set-thresholds
  setup-indicators
  
  reset-ticks
end
  
to mini-go
  reset-roundActiveCounts
  reset-weight-sums
  reset-consider
  reset-payoffs
  
  propagate-influence
  make-adoption-decision
  
  update-indicators
  
  tick
end

to set-active [b-id seedset]
  ask seedset [
    array:set actives? b-id true
    set-color
    if array:item costs b-id > resource [
      set resource array:item costs b-id
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Code for avoiding behaviorSpace;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go-bspace
  ;set average-spread 0
  ;set sd-spread 0
  setup-stats
  let rand-seed rand-seed-threshold
  ;let num-samples-for-spread-estimation 1000
  repeat num-samples-for-spread-estimation [
    mock-setup rand-seed
    set rand-seed rand-seed + 1
    let step-count 0
    while [(not no-new-adoption?) and (step-count < max-step)] [
      mini-go
      set step-count step-count + 1
    ] 
    ;let spread-est count turtles with [active?]
    ;set average-spread average-spread + spread-est
    ;set sd-spread sd-spread + (spread-est * spread-est)
    update-stats
  ]
  ;set average-spread average-spread / num-samples-for-spread-estimation
  ;set sd-spread sd-spread / num-samples-for-spread-estimation
  ;set sd-spread sqrt (sd-spread - (average-spread * average-spread))
  finalize-stats num-samples-for-spread-estimation
end

to mock-setup [rand-seed]
  set-actives
  set-neutral-color
  ;restore-resource
  set-seeds-active seed-sets
  random-seed 1234567 + rand-seed
  set-thresholds
  setup-indicators
  
  reset-ticks
end

to setup-stats
  set total-part-mean 0
  set total-part-sd 0
  set total-adopt-mean 0
  set total-adopt-sd 0
  set util-mean 0
  set util-sd 0
  set act-counts-mean array:from-list all-zeros
  set act-counts-sd array:from-list all-zeros
end
  
to update-stats
  set total-part-mean total-part-mean + total-active-count
  set total-part-sd total-part-sd + (total-active-count * total-active-count)
  set total-adopt-mean total-adopt-mean + total-unique-active-count
  set total-adopt-sd total-adopt-sd + (total-unique-active-count * total-unique-active-count)
  set util-mean util-mean + utilization
  set util-sd util-sd + (utilization * utilization)
  foreach behav-id-list [
    array:set act-counts-mean ? (array:item act-counts-mean ?) + (array:item active-counts ?)
    array:set act-counts-sd ? (array:item act-counts-sd ?) + (array:item active-counts ?) * (array:item active-counts ?)
  ]
end 

to finalize-stats [n]
  set total-part-mean total-part-mean / n
  set total-part-sd total-part-sd / n
  set total-part-sd sqrt (total-part-sd - (total-part-mean * total-part-mean))
  
  set total-adopt-mean total-adopt-mean / n
  set total-adopt-sd total-adopt-sd / n
  set total-adopt-sd sqrt (total-adopt-sd - (total-adopt-mean * total-adopt-mean))
  
  set util-mean util-mean / n
  set util-sd util-sd / n
  set util-sd sqrt (util-sd - (util-mean * util-mean))
  
  foreach behav-id-list [
    array:set act-counts-mean ? (array:item act-counts-mean ?) / n
    array:set act-counts-sd ? (array:item act-counts-sd ?) / n
    array:set act-counts-sd ? sqrt ((array:item act-counts-sd ?) - (array:item act-counts-mean ?) * (array:item act-counts-mean ?))
  ]
end
  

;;;;;;;;;;;;;;;;;;;;;;
;;;Linear Threshold;;;
;;;;;;;;;;;;;;;;;;;;;;

to go
  if no-new-adoption? [stop]
  
  reset-roundActiveCounts
  reset-weight-sums
  reset-consider
  reset-payoffs
  
  propagate-influence
  make-adoption-decision
  
  update-indicators
  
  tick
end

to-report no-new-adoption?
  let new-adoption reduce + array:to-list roundActiveCounts
  ifelse new-adoption = 0
  [report true]
  [report false]
end 

to reset-roundActiveCounts
  set roundActiveCounts array:from-list all-zeros
end

to reset-weight-sums
  ask turtles [
    set weight-sums array:from-list all-zeros
  ]
end

to reset-consider
  ask turtles [
    foreach behav-id-list [
      array:set consider? ? (array:item actives? ?)   ;; previously adopted behaviors are automatically considered
      ;array:set consider? ? false ; only behaviors crossing the threshold are considered
    ]
  ]
end

to reset-payoffs
  ask turtles [
    set payoffs array:from-list all-zeros
  ]
end    

to propagate-influence 
  ask turtles [
    foreach behav-id-list [
      if array:item actives? ?
      [
        ask my-links [
          influence myself ?
          ;set color (base + ? * step)
        ]
      ]
    ]
  ]
end

;; link procedure; influencer influences the other end of the link; link procedure
to influence [influencer behav-id]
  ifelse end1 = influencer [
    let weight end2-weight
    ask end2 [
      let t array:item weight-sums behav-id
      array:set weight-sums behav-id ( t + weight )
    ]
  ]
  [
    let weight end1-weight
    ask end1 [
      let t array:item weight-sums behav-id
      array:set weight-sums behav-id ( t + weight )
    ]
  ]
end

;; decision to turn active or not
to make-adoption-decision
  ask turtles [
    calculate-payoffs
    new-consider
    
    let opt knapsack-decide
    
    foreach behav-id-list [
     array:set actives? ? false
    ]
  
    foreach opt [
     array:set actives? ? true
    ]
    
    ifelse empty? opt [
      set color neutral
    ]
    [
      set-color
    ]
  ]
end

;; turtle procedure; calculate the present payoffs for each behavior
to calculate-payoffs
  let w 0.5
  let extra 0
  if switching-cost? [
    set extra benefit-of-inertia
  ]
  
  foreach behav-id-list [
    array:set payoffs ? w * (array:item utilities ? + extra) + (1 - w) * (array:item weight-sums ?)
  ]
end

;; turtle procedure to check which behaviors cross the node thresholds
to new-consider
   foreach behav-id-list [
     if (array:item weight-sums ?) >= (array:item thresholds ?) [
       array:set consider? ? true
     ]
   ]
end

;; turtle procedure for adoption decision making
;; employs brute-force search for the knapsack problem
;; ; should implement dynamic programing version of the knapsack algorithm
to-report knapsack-decide 
  let consider-behav-list filter [array:item consider? ?] behav-id-list
  
  let power-set compute-power-set consider-behav-list
  
  let opt [] 
  let max-payoff 0
  foreach power-set [
    let total-cost 0
    foreach ? [
      set total-cost total-cost + (array:item costs ?)
    ]
    if total-cost <= resource [
      let total-payoff 0
      foreach ? [
        set total-payoff total-payoff + (array:item payoffs ?)
      ]
      if total-payoff > max-payoff [
        set max-payoff total-payoff
        set opt ?
      ]
    ]
  ]
  
  report opt
end

to-report compute-power-set [list-of-items]
;  ifelse empty? list-of-items [
;    report [[]]
;  ]
;  [
;    let head first list-of-items
;    let rest but-first list-of-items
;   let rest-power-set compute-power-set rest
;    let new-subsets []
;    foreach rest-power-set [
;      set new-subsets sentence new-subsets (list (sentence ? head))
;   ]
;    report sentence rest-power-set new-subsets
;  ]
  
  report compute-power-set-tail-recursive [[]] list-of-items
end

to-report compute-power-set-tail-recursive [list-of-subsets list-of-items]
  ifelse empty? list-of-items [
    report list-of-subsets
  ]
  [
    let head first list-of-items
    let list-of-new-subsets map [sentence ? head] list-of-subsets
    report compute-power-set-tail-recursive (sentence list-of-subsets list-of-new-subsets) (but-first list-of-items)
  ]
end
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Reporters for User Interface;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-indicators 
  set total-resource sum [resource] of turtles
  
  set total-active-count count turtles with [active?]
  
  set active-counts array:from-list n-values num-behaviors [count turtles with [array:item actives? ?]]
  
  set old-active-counts array:from-list all-zeros
  
  set total-unique-active-count sum array:to-list active-counts
  
  let utilized-resource 0
  foreach behav-id-list [
    set utilized-resource utilized-resource + (array:item active-counts ? * array:item costs ?)
  ]
  
  set utilization utilized-resource / total-resource
  
  set roundActiveCounts array:from-list array:to-list active-counts
end

to update-indicators
  set total-active-count count turtles with [active?]
  
  foreach behav-id-list [
    array:set old-active-counts ? array:item active-counts ?
  ]
  
  foreach behav-id-list [
    array:set active-counts ? count turtles with [array:item actives? ?]
  ]
  
  foreach behav-id-list [
    array:set roundActiveCounts ? (array:item active-counts ? - array:item old-active-counts ?)
  ]
  
  set total-unique-active-count sum array:to-list active-counts
  
  let utilized-resource 0
  foreach behav-id-list [
    set utilized-resource utilized-resource + (array:item active-counts ? * array:item costs ?)
  ]
  
  set utilization utilized-resource / total-resource
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Auxiliary Procedures;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; turtle procedure
to set-color
  set color 0
  let num 0
  foreach behav-id-list [
    if array:item actives? ? [
      set color color + (base + ? * step)
      set num num + 1
    ]
  ]
  if num > 1 [
    set color color + scaling
  ]
end
  

;; turtle procedure
to-report active?
  foreach behav-id-list [
    if array:item actives? ? [
      report true
    ]
  ]
  report false
end
     
    
  
@#$#@#$#@
GRAPHICS-WINDOW
917
21
1580
705
20
20
15.93
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

SLIDER
23
36
195
69
number-of-nodes
number-of-nodes
1
2000
500
1
1
NIL
HORIZONTAL

SLIDER
23
345
206
378
total-num-seeds
total-num-seeds
1
number-of-nodes
51
1
1
NIL
HORIZONTAL

SLIDER
20
673
207
706
rand-seed-network
rand-seed-network
1
10000
5476
1
1
NIL
HORIZONTAL

SLIDER
23
74
195
107
rewiring-probability
rewiring-probability
0
1
0.2
0.01
1
NIL
HORIZONTAL

BUTTON
311
23
374
56
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
312
74
375
107
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
282
213
415
258
total-active-count
total-active-count
17
1
11

SLIDER
24
145
196
178
num-behaviors
num-behaviors
1
10
3
1
1
NIL
HORIZONTAL

MONITOR
282
273
415
318
NIL
total-unique-active-count
17
1
11

MONITOR
284
337
415
382
NIL
utilization
5
1
11

PLOT
502
28
811
230
per-behavior-adoption
time
active-count
0.0
10.0
0.0
10.0
true
true
"foreach n-values num-behaviors [?] [\n create-temporary-plot-pen word \"b\" ?\n set-plot-pen-color base + ? * step\n]" "foreach n-values num-behaviors [?] [\n set-current-plot \"per-behavior-adoption\"\n set-current-plot-pen word \"b\" ?\n plot array:item active-counts ?\n]"
PENS

PLOT
501
260
813
454
total-adoption
time
active-counts
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"unique-adoption" 1.0 0 -3844592 true "" "plot total-unique-active-count"
"spread" 1.0 0 -14454117 true "" "plot total-active-count"

PLOT
501
488
815
678
utilization
time
utilization
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot utilization"

INPUTBOX
24
185
196
245
behavior-costs
[0.2 0.5 0.7]
1
0
String

INPUTBOX
24
250
197
310
behavior-utilities
[0.2 0.5 0.7]
1
0
String

TEXTBOX
25
10
175
30
Specify the Network
16
0.0
1

TEXTBOX
25
116
198
146
Specify the Behaviors
16
0.0
1

TEXTBOX
26
318
176
338
Specify the Seeds
16
0.0
1

TEXTBOX
23
644
189
684
Control Randomization
16
0.0
1

TEXTBOX
25
494
175
514
Diffusion Model
16
0.0
1

SWITCH
22
560
207
593
switching-cost?
switching-cost?
1
1
-1000

SWITCH
22
522
207
555
matched-threshold?
matched-threshold?
1
1
-1000

SLIDER
22
601
206
634
benefit-of-inertia
benefit-of-inertia
0
1
0.2
0.01
1
NIL
HORIZONTAL

CHOOSER
23
441
207
486
seed-selection-algorithm
seed-selection-algorithm
"ideal-all-agent-adoption-without-network-effect" "randomly-unlimited-seed-resource-batched" "randomly-unlimited-seed-resource-incremental" "randomly-with-available-resource-batched" "randomly-with-available-resource-incremental" "randomly-with-knapsack-assignment" "randomly-with-random-tie-breaking" "naive-degree-ranked-with-knapsack-assignment" "naive-degree-ranked-with-random-tie-breaking-no-nudging" "naive-degree-ranked-with-random-tie-breaking-with-nudging" "degree-and-resource-ranked-with-knapsack-tie-breaking" "degree-and-resource-ranked-with-random-tie-breaking" "one-step-spread-ranked-with-random-tie-breaking" "one-step-spread-hill-climbing-with-random-tie-breaking" "spread-based-hill-climbing-with-random-tie-breaking"
14

SLIDER
20
712
207
745
rand-seed-resource
rand-seed-resource
0
10000
3852
1
1
NIL
HORIZONTAL

SLIDER
21
753
207
786
rand-seed-threshold
rand-seed-threshold
0
10000
1000
1
1
NIL
HORIZONTAL

CHOOSER
23
386
206
431
seed-distribution
seed-distribution
"uniform" "proportional to cost" "inversely proportional to cost" "highest cost behavior only" "lowest cost behavior only" "in ratio"
4

INPUTBOX
258
403
432
463
final-ratio
[3 2 1]
1
0
String

SLIDER
258
482
434
515
num-sim-for-spread-based-seed-selection
num-sim-for-spread-based-seed-selection
1
10000
1000
1
1
NIL
HORIZONTAL

SLIDER
259
542
431
575
max-step
max-step
0
500
50
1
1
NIL
HORIZONTAL

SLIDER
248
119
446
152
num-samples-for-spread-estimation
num-samples-for-spread-estimation
1
10000
5000
1
1
NIL
HORIZONTAL

BUTTON
301
162
390
195
NIL
go-bspace\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This a model of social behavior diffusion with multiple behaviors diffusing in the social network simultaneously. Each behavior has an associated cost and utility. Each agent has a finite resource for adoption of different behaviors. Agents further derive local network utility based on how many of its neighbors has adopted the behavior. Adoption decision is based on a social influence based triggering mechanism controlled by an agent spefic random threshold, and utility maximization mechanism at each individual agent level.

## HOW IT WORKS

At each time step each agent looks around its neighborhood and watches what behaviors are adopted by its neighbors and the influence weight of how many of them crosses its threshold. Then it calculates the total utility of each of the behaviors for which the total influence weight crosses the threhsold and computes the set of the behaviors for which the total utility is maximized subject to the resource constraint.

## HOW TO USE IT

Set the network parameters for network generation. For example set number-of-nodes to 500, and average-node-degree to 10. Specify the number of behaviors and the associated cost. For example if num-behaviors is set to zero, then specify behavior-costs as - "[0.2 0.3 0.4]" (without the quotes) and the behavior-utilities as - "[0.2 0.3 0.4]" (again without the quotes). Set a value for number-of-seeds-per-behavior. Then press setup button to initialize the model and go to run it.

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="seed-selection-heuristic-comparison" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;randomly-with-random-tie-breaking&quot;"/>
      <value value="&quot;degree-and-resource-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-distribution" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;proportional to cost&quot;"/>
      <value value="&quot;inversely proportional to cost&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-heuristic-comparison-network-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;randomly-with-random-tie-breaking&quot;"/>
      <value value="&quot;degree-and-resource-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-distribution-network-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;proportional to cost&quot;"/>
      <value value="&quot;inversely proportional to cost&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-distribution-switching-cost-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;proportional to cost&quot;"/>
      <value value="&quot;inversely proportional to cost&quot;"/>
      <value value="&quot;highest cost behavior only&quot;"/>
      <value value="&quot;lowest cost behavior only&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-distribution-switching-cost-network-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;proportional to cost&quot;"/>
      <value value="&quot;inversely proportional to cost&quot;"/>
      <value value="&quot;highest cost behavior only&quot;"/>
      <value value="&quot;lowest cost behavior only&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="max-utilization-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;ideal-all-agent-adoption-without-network-effect&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="max-utilization-network-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;ideal-all-agent-adoption-without-network-effect&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-heuristic-comparison-extra-switchingc-cost-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;naive-degree-ranked-with-knapsack-assignment&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-no-nudging&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-with-nudging&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-size-vs-utilization-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <metric>array:item num-seeds-per-behavior 0</metric>
    <metric>array:item num-seeds-per-behavior 1</metric>
    <metric>array:item num-seeds-per-behavior 2</metric>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="100"/>
      <value value="200"/>
      <value value="300"/>
      <value value="400"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-heuristic-comparison-extra-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;naive-degree-ranked-with-knapsack-assignment&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-no-nudging&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-with-nudging&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-heuristic-comparison-switching-cost-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;randomly-with-random-tie-breaking&quot;"/>
      <value value="&quot;degree-and-resource-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-sw-c-network-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;randomly-with-random-tie-breaking&quot;"/>
      <value value="&quot;degree-and-resource-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
      <value value="&quot;naive-degree-ranked-with-knapsack-assignment&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-no-nudging&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-with-nudging&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-n-sw-c-network-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;naive-degree-ranked-with-knapsack-assignment&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-no-nudging&quot;"/>
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-with-nudging&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="behav-distribution-n-sw-cost-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;highest cost behavior only&quot;"/>
      <value value="&quot;lowest cost behavior only&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="final-distribution-n-sw-cost-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;proportional to cost&quot;"/>
      <value value="&quot;inversely proportional to cost&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="initial-to-final-ratio-n-sw-cost-threshold" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[1 2 3]&quot;"/>
      <value value="&quot;[1 3 2]&quot;"/>
      <value value="&quot;[2 1 3]&quot;"/>
      <value value="&quot;[2 3 1]&quot;"/>
      <value value="&quot;[3 1 2]&quot;"/>
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;in ratio&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
  </experiment>
  <experiment name="seed-selection-heuristic-comparison-switching-cost-threshold-average-repeat" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="naive-seed-size-vs-utilization-threshold-average" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <metric>array:item num-seeds-per-behavior 0</metric>
    <metric>array:item num-seeds-per-behavior 1</metric>
    <metric>array:item num-seeds-per-behavior 2</metric>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="2999"/>
    <enumeratedValueSet variable="switching-cost?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-with-nudging&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
      <value value="300"/>
      <value value="400"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="naive-seed-size-vs-utilization-threshold-average-n-sw-cost" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <metric>array:item num-seeds-per-behavior 0</metric>
    <metric>array:item num-seeds-per-behavior 1</metric>
    <metric>array:item num-seeds-per-behavior 2</metric>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="1000" step="1" last="5999"/>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;naive-degree-ranked-with-random-tie-breaking-with-nudging&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
      <value value="300"/>
      <value value="400"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="greedy-approx-seed-selection" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go-bspace</go>
    <timeLimit steps="1"/>
    <metric>total-part-mean</metric>
    <metric>total-part-sd</metric>
    <metric>total-adopt-mean</metric>
    <metric>total-adopt-sd</metric>
    <metric>util-mean</metric>
    <metric>util-sd</metric>
    <metric>array:item act-counts-mean 0</metric>
    <metric>array:item act-counts-sd 0</metric>
    <metric>array:item act-counts-mean 1</metric>
    <metric>array:item act-counts-sd 1</metric>
    <metric>array:item act-counts-mean 2</metric>
    <metric>array:item act-counts-sd 2</metric>
    <enumeratedValueSet variable="num-samples-for-spread-estimation">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;spread-based-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
