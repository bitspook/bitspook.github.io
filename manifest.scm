(use-modules (guix packages)
             (gnu packages base))

(packages->manifest (list gnu-make))
