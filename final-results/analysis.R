results <- read.csv("~/Documents/research/tmp/shill-performance-tests/final-results/results.csv", header=F)
means <- data.frame("experiment" = results[,1],"mean" = rowMeans(results[,2:51]),"sd" = apply(results[,2:51],1,sd))
means$ci <- means$sd * qnorm(0.975)

fourup <- function (a, b, c, d) {
  ab.value = t.test(results[results$V1 == a,2:51],results[results$V1 == b,2:51])$p.value
  ac.value = t.test(results[results$V1 == a,2:51],results[results$V1 == c,2:51])$p.value
  ad.value = t.test(results[results$V1 == a,2:51],results[results$V1 == d,2:51])$p.value
  cbind(means[means$experiment == a,2],
        means[means$experiment == a,4],
        means[means$experiment == b,2],
        means[means$experiment == b,4],
        ((means[means$experiment == b,2] - means[means$experiment == a,2]) / means[means$experiment == a,2]) * 100,
        ab.value,
        ab.value < (0.05 / 3),
        means[means$experiment == c,2],
        means[means$experiment == c,4],
        ((means[means$experiment == c,2] - means[means$experiment == a,2]) / means[means$experiment == a,2]) * 100,
        ac.value,
        ac.value < (0.05 / 3),
        means[means$experiment == d,2],
        means[means$experiment == d,4],
        ((means[means$experiment == d,2] - means[means$experiment == a,2]) / means[means$experiment == a,2]) * 100,
        ad.value,
        ad.value < (0.05 / 3))
}

threeup <- function (a, b, c) {
  ab.value = t.test(results[results$V1 == a,2:51],results[results$V1 == b,2:51])$p.value
  ac.value = t.test(results[results$V1 == a,2:51],results[results$V1 == c,2:51])$p.value
  cbind(means[means$experiment == a,2],
        means[means$experiment == a,4],
        means[means$experiment == b,2],
        means[means$experiment == b,4],
        ((means[means$experiment == b,2] - means[means$experiment == a,2]) / means[means$experiment == a,2]) * 100,
        ab.value,
        ab.value < (0.05 / 2),
        means[means$experiment == c,2],
        means[means$experiment == c,4],
        ((means[means$experiment == c,2] - means[means$experiment == a,2]) / means[means$experiment == a,2]) * 100,
        ac.value,
        ac.value < (0.05 / 2),
        0,0,0,0,0)
}

table <-
rbind(fourup("grading-none", "grading-bash","grading-sandbox","grading-shill"),
      fourup("emacs-none", "emacs-bash","emacs-sandbox","emacs-shill"),
      threeup("curl-none", "curl-bash", "curl-sandbox"),
      threeup("untar-none", "untar-bash", "untar-sandbox"),
      threeup("configure-none", "configure-bash", "configure-sandbox"),
      threeup("make-none", "make-bash", "make-sandbox"),
      threeup("install-none", "install-bash", "install-sandbox"),
      threeup("uninstall-none", "uninstall-bash", "uninstall-sandbox"),
      threeup("apache-none", "apache-native", "apache-sandbox"),
      fourup("find-none", "find-no-sandbox", "find-exec-sandbox", "find-exec-shill-yes-spawn"))

print(table,digits=2)