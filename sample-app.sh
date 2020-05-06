#!/bin/bash
mk run springboot-app --image=pasapples/spring-boot-jib --replicas=1 --port=8080
mk expose deployment springboot-app --port=80 --target-port=8080 --type=LoadBalancer
