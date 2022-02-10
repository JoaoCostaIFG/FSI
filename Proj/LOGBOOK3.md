# CVE-2013-2094 characterization (3rd week)

## Identification

- This vulnerability affects the Linux kernel before version 3.8.9 (introduced
  in commit `b0a873ebb`).
- The perf_swevent_init function in kernel/events/core.c is vulnerable to an
  out-of-bounds array access.
- The out-of-bounds access mentioned is caused by the use of an incorrect
  integer data type.
- All systems using an unpatched Linux kernel are vulnerable.

## Cataloging

- On the CVSS version 2.0 the vulnerability scores 7.2 (HIGH).
- It was reported (no bug-bounty) by Tommi Rantala <tt.rantala@gmail.com>
  at 2013-04-12 that discovered it while "fuzzing with trinity".
- It was marked as urgent on git.kernel.org and
  [patched](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=8176cced706b5e5d15887584150764894e94e02f)
  by the reporter one day later.
- The patch changed the integer data type of event_id on perf_swevent_init from
  int to u64.

## Exploit

- This vulnerability can be exploited to achieve privilege escalation on a
  vulnerable system.
- An automated exploit to spawn a root shell can be found on
  [exploit-db](https://www.exploit-db.com/exploits/33589).
- This exploit was submited by [Vitaly Nikolenko](https://www.exploit-db.com/?author=7334)
  on 2014-05-31.
- The original exploit can be found
  [here](https://web.archive.org/web/20130515231440/http://fucksheep.org/~sd/warez/semtex.c)

## Attacks

- The Linux.BtcMine.174 Trojan exploits both this vulnerability as well as CVE-2016-5195.
- The Trojan above as been found to infect networks worldwide.
- Once it infects the target machine, it sets itself as a daemon and downloads
  the payload (containing more malware).
- Detailed information about the Trojan above can be found
  [here](https://vms.drweb.com/virus/?i=17663595&lng=en)
