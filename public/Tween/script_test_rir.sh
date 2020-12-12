#!/bin/bash

# bash script to test rir post
# can run using `time` to get execution time

curl http://localhost:5000/rir-gen -X POST \
-d "sourceX=3.0" -d "sourceY=2.0" -d "sourceZ=1.0" \
-d "receiverX=3.0" -d "receiverY=3.0" -d "receiverZ=1.0" \
-d "azimuth=0.0" -d "elevation=0.0" \
-d "roomX=6" -d "roomY=6" -d "roomZ=3" \
-d "coef1=0.1" -d "coef2=0.1" -d "coef3=0.1" \
-d "coef4=0.1" -d "coef5=0.1" -d "coef6=0.1"
