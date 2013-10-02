extensions [array]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  let network-generation-task task [setup-small-world-network]
  generic-setup network-generation-task
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
  layout-circle (sort turtles) max-pxcor - 1
end

to wire-them
  ;; iterate over the turtles
  let n 0
  while [n < count turtles]
  [
    ;; make edges with the next two neighbors
    ;; this makes a lattice with average degree of 4
    let edge 1
    while [edge <= no-edges]
    [
    make-edge turtle n
              turtle ((n + edge) mod count turtles)
              set edge edge + 1
     ]
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

;;;;;;;;;;;;;;;;;;;;;;;;
;;;Included Sources ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

__includes [
  ;; generic setup
  "generic_setup.nls"
  
  ;; parameter initializaton
  "param_initialization.nls"
  
  ;; seed selection algorithm selection switch 
  "seed_selection_algo_switch.nls" 
  
  ;; behavior distribution algorithms
  "behav_dist_algo.nls"
  
  ;; ideal adoption utilization
  "ideal_all_agent_adoption_without_network_effect.nls"
  
  ;; common seed selection procedures
  "seed_selection_common.nls"
  
  ;; random seed selection algorithms
  "random_seed_selection.nls"
  
  ;; degree centrality based seed selection algorithms
  "deg_cent_seed_selection.nls"
  
  ;; expected one step adoption based selection
  "one_step_adopt_seed_selection.nls"
  
  ;; greedy approximation seed selection algorithm
  "greedy_approx_seed_selection.nls"
  
  ;; simulation loop (functions as a mini BehaviorSpace)
  "simulation_loop.nls"
  
  ;; model of multiple behavior diffusion 
  "diffusion_model.nls"
  
  ;; simulation count variables
  "simulation_count_vars.nls"
    
  ;; simulation count variables
  "simulation_count_vars.nls"
  
  ;; network dynamics
  "network_dynamics.nls"
  
  ;; calculates payoffs which is a combination of intrinsic and extrensic properties
  "calculate_payoffs.nls"
]    
    
@#$#@#$#@
GRAPHICS-WINDOW
838
33
1460
676
20
20
14.93
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
100
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
10
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
2164
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
0
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
NIL
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
1
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
3
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
[0.5]
1
0
String

INPUTBOX
24
250
197
310
behavior-utilities
[0.5]
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
226
486
seed-selection-algorithm
seed-selection-algorithm
"ideal-all-agent-adoption-without-network-effect" "randomly-unlimited-seed-resource-batched" "randomly-unlimited-seed-resource-incremental" "randomly-with-available-resource-batched" "randomly-with-available-resource-incremental" "randomly-with-knapsack-assignment" "randomly-with-random-tie-breaking" "naive-degree-ranked-with-knapsack-assignment" "naive-degree-ranked-with-random-tie-breaking-no-nudging" "naive-degree-ranked-with-random-tie-breaking-with-nudging" "degree-and-resource-ranked-with-knapsack-tie-breaking" "degree-and-resource-ranked-with-random-tie-breaking" "one-step-spread-ranked-with-random-tie-breaking" "one-step-spread-hill-climbing-with-random-tie-breaking" "IA-S-T" "IA-S-NT" "IA-M-T" "IA-M-NT" "KKT-S-T" "KKT-S-NT" "KKT-M-T" "KKT-M-NT"
13

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
4995
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
0

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
200
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

BUTTON
403
49
483
82
run-expt
setup\ngo-bspace\nshow seed-selection-algorithm\nshow total-part-mean\nshow total-part-sd\nshow total-adopt-mean\nshow total-adopt-sd\nshow act-counts-mean\nshow act-counts-sd\nshow util-mean\nshow util-sd
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
21
799
207
832
rand-seed-duration
rand-seed-duration
0
10000
1967
1
1
NIL
HORIZONTAL

MONITOR
290
591
414
636
NIL
max-utilization
3
1
11

TEXTBOX
861
689
1106
729
Select Time Varying Parameters
16
0.0
1

SWITCH
861
722
1016
755
global-influence
global-influence
0
1
-1000

SWITCH
862
775
1017
808
cost-varying?
cost-varying?
1
1
-1000

SWITCH
1049
722
1256
755
threshold-varying?
threshold-varying?
1
1
-1000

SWITCH
1049
776
1258
809
varying-avialable-resources
varying-avialable-resources
1
1
-1000

TEXTBOX
1505
27
1704
67
Select Duration Model
16
0.0
1

CHOOSER
1505
75
1710
120
duration-model
duration-model
"SIR" "SIRS" "SIvRS" "sticky-behavior" "none"
1

TEXTBOX
1508
169
1658
189
Insert Durations
16
0.0
1

INPUTBOX
1506
218
1767
278
behavior-durations-mean
[2]
1
0
String

INPUTBOX
1507
300
1769
360
behavior-durations-sd
[0]
1
0
String

INPUTBOX
1506
385
1772
445
behavior-recovered-duration
[1]
1
0
String

SLIDER
277
705
449
738
no-edges
no-edges
0
number-of-nodes
98
1
1
NIL
HORIZONTAL

MONITOR
292
654
384
699
NIL
total-adoption
17
1
11

SLIDER
1289
724
1479
757
positive-effect-probability
positive-effect-probability
0
1
1
0.1
1
NIL
HORIZONTAL

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
NetLogo 5.0.3
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
  <experiment name="comp-with-greedy-th-ave-matched-th" repetitions="1" runMetricsEveryStep="false">
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
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;spread-based-hill-climbing-incremental-one-behav-per-seed&quot;"/>
      <value value="&quot;spread-based-hill-climbing-incremental&quot;"/>
      <value value="&quot;one-step-spread-ranked-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-incremental-one-behav-per-seed&quot;"/>
      <value value="&quot;one-step-spread-hill-climbing-incremental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="5476"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="seed-selection-n-sw-c-network-average-IA-S-T" repetitions="1" runMetricsEveryStep="false">
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
      <value value="&quot;IA-S-T&quot;"/>
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
  <experiment name="seed-selection-ia-s-t-n-sw-net-av" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>total-active-count</metric>
    <metric>total-unique-active-count</metric>
    <metric>array:item active-counts 0</metric>
    <metric>array:item active-counts 1</metric>
    <metric>array:item active-counts 2</metric>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-threshold">
      <value value="4937"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;IA-S-T&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-network" first="1000" step="1" last="1999"/>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.2 0.5 0.7]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-samples-for-spread-estimation">
      <value value="5000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SIRS-SW-threshold-average-global-influence" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>max-utilization</metric>
    <metric>total-adoption</metric>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-samples-for-spread-estimation">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-edges">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="varying-avialable-resources">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-mean">
      <value value="&quot;[2]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-duration">
      <value value="1967"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-influence">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-recovered-duration">
      <value value="&quot;[1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration-model">
      <value value="&quot;SIRS&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="2164"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-sd">
      <value value="&quot;[0]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="4000" step="1" last="4999"/>
  </experiment>
  <experiment name="SIR-SIvS-SIRS-complete-max-utlization-global-influence" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>max-utilization</metric>
    <metric>total-adoption</metric>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-samples-for-spread-estimation">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-recovered-duration">
      <value value="&quot;[1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-influence">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-duration">
      <value value="1967"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-sd">
      <value value="&quot;[0]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-edges">
      <value value="98"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration-model">
      <value value="&quot;none&quot;"/>
      <value value="&quot;SIR&quot;"/>
      <value value="&quot;SIRS&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-mean">
      <value value="&quot;[2]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="4000" step="1" last="4999"/>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="varying-avialable-resources">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="2164"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SIvRS-Complete-graph-threshold-avg-max-utlization" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>max-utilization</metric>
    <metric>total-adoption</metric>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-samples-for-spread-estimation">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-recovered-duration">
      <value value="&quot;[0]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-influence">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-duration">
      <value value="1967"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-sd">
      <value value="&quot;[0]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-edges">
      <value value="98"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration-model">
      <value value="&quot;SIvRS&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-mean">
      <value value="&quot;[2]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="4000" step="1" last="4999"/>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="varying-avialable-resources">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="2164"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SI-SIR-SIvRS-SW-threshold-average-global-influence" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>utilization</metric>
    <metric>max-utilization</metric>
    <metric>total-adoption</metric>
    <enumeratedValueSet variable="rand-seed-resource">
      <value value="3852"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-samples-for-spread-estimation">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-num-seeds">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-edges">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="varying-avialable-resources">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sim-for-spread-based-seed-selection">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-costs">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="benefit-of-inertia">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-mean">
      <value value="&quot;[2]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-duration">
      <value value="1967"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-behaviors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed-selection-algorithm">
      <value value="&quot;one-step-spread-hill-climbing-with-random-tie-breaking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-influence">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-recovered-duration">
      <value value="&quot;[1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-varying?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matched-threshold?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration-model">
      <value value="&quot;none&quot;"/>
      <value value="&quot;SIR&quot;"/>
      <value value="&quot;SIvRS&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-step">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switching-cost?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewiring-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-seed-network">
      <value value="2164"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-durations-sd">
      <value value="&quot;[0]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="final-ratio">
      <value value="&quot;[3 2 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="behavior-utilities">
      <value value="&quot;[0.5]&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="rand-seed-threshold" first="4000" step="1" last="4999"/>
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
