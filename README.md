# varnish-fork-exhaust

A minimal reproducer of thread exhaustion on AKS with varnish pods.


Build:
```bash
$ docker build . -t docker.io/alexeldeib/varnish:7.2.1
$ docker push docker.io/alexeldeib/varnish:7.2.1
```

Deploy:
```bash
$ kubectl apply -f deploy.yaml
```

The default config uses 20 thread pools each with 5000 threads (100k total).

The default for `kernel.threads-max` appears to be dependent on machine size.

On my 4 core 16 gigabyte machine, I get ~128k threads.

128k - 100k ~= 28k. So running two of these pods on one node should trigger pid exhaustion.

But it doesn't! Why?

Varnish doesn't seem to max out all pools, even when setting THREAD_POOL_MIN.

In my testing, varnish seems to refuse using more than 32k pids initially.

Incidentally this is quite close to the default 32bit system limit.

This can be verified with a command like the following:
```bash
# ps -eL -o pid,tid,comm | grep varnish | wc -l
2
# ps -eL -o pid,tid,comm | grep cache-worker | wc -l
65056
```

Here we have two varnish instances, each with 65056/2=32753 pids.

The 32-bit pid_max default is 32768 -- only 15 pids difference.

Perhaps varnish has some internal defaulting/pool buffering behavior?

On a system under load, with multiple instances, this should quickly max out pids.
