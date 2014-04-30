latency <- read.csv("~/Documents/research/tmp/shill-performance-tests/final-results/latency.csv", header=F)
ab.value = t.test(latency[latency$V1 == "apache-none",2:51],latency[latency$V1 == "apache-native",2:51])$p.value
ac.value = t.test(latency[latency$V1 == "apache-none",2:51],latency[latency$V1 == "apache-sandbox",2:51])$p.value