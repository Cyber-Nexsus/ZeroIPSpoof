# ZeroIPSpoof

![Project Banner](./ChatGPT%20Image%20Jun%202%2C%202026%2C%2001_08_01%20PM.jpg)

সংক্ষেপে
---------
ZeroIPSpoof একটি সহায়ক রিপোজিটরি যা অনুমোদিত (authorized) পেন-টেস্টিং ও বাগ-বাউন্টি ওয়ার্কফ্লো দ্রুত শুরু করার জন্য টুল ইনস্টলেশন ও নিরাপদ অটোমেশন স্ক্রিপ্ট প্রদান করে। এই প্রোজেক্টটি কোনো WAF/CDN বাইপাস, আইপি-স্পুফিং বা অন্য কোনো অননুমোদিত এভেশন টেকনিক তৈরি বা চালায় না।

সতর্কতা ও লিগ্যাল নোট (অবশ্যক)
-------------------------------
- এই রিপোজিটরির সব স্ক্রিপ্ট **শুধুমাত্র** সেইসব লক্ষ্যবস্তুতে ব্যবহার করুন যেগুলোর জন্য আপনার কাছে **স্পষ্ট লিখিত অনুমতি (explicit written permission)** আছে।
- অননুমোদিত স্ক্যান বা আক্রমণ আইনগত ও নৈতিকভাবে অপরাধ হতে পারে।
- স্ক্যান চালানোর আগে সবসময় আপনার Rules of Engagement (ROE) এবং অনুমতির কপি সংরক্ষণ করুন।

ইনস্টলেশন
-----------
রিপো মূল ডাইরেক্টরিতে থাকা `install.sh` স্ক্রিপ্টটি Debian/Ubuntu/Kali-ভিত্তিক সিস্টেমে সাধারণ পেন-টেস্ট টুলগুলো ইনস্টল করবে (nmap, hping3, proxychains4, masscan, sqlmap, nikto, ইত্যাদি)।

চালানোর উদাহরণ:

```bash
chmod +x install.sh
./install.sh
```

Install স্ক্রিপ্টটি চালানোর সময় এটি আপনাকে নিশ্চিতকরণ (Type YES) চাইবে যে আপনার কাছে লিখিত অনুমতি আছে — না থাকলে ইনস্টল বন্ধ হবে।

Run Instructions (Scan Runner)
-----------------------------
রিপোতে একটি নিরাপদ স্ক্যান রানার আছে: `tools/run_scans.sh`। এটি অনুমোদিত এনগেজমেন্টে প্রি-কনফিগার করা nmap/proxychains কমান্ডগুলো চালাতে সাহায্য করে এবং আউটপুট স্বয়ংক্রিয়ভাবে লগ করে রাখে।

উদাহরণ:

```bash
chmod +x tools/run_scans.sh
# Quick TCP scan using proxychains and an NSE script named "vuln"
./tools/run_scans.sh --target example.com --mode quick_tcp --script vuln

# HTTP focused vulnerability scan
./tools/run_scans.sh --target example.com --mode http_vuln

# NTP (UDP) info (requires sudo) — নোট: UDP proxied নয়
sudo ./tools/run_scans.sh --target 1.2.3.4 --mode ntp_info

# Dry-run (only prints commands)
./tools/run_scans.sh --target example.com --mode quick_tcp --script vuln --dry-run
```

Modes (সংক্ষিপ্ত)
- quick_tcp: proxychains4 nmap -sT -Pn --open --script=<script>
- vuln_scan: proxychains4 nmap -sS -O -sU --script=vuln (নির্ধারণকৃত সতর্কতা—-sU UDP ব্যবহার করে)
- slow_vuln: proxychains4 nmap -sT -Pn -T1 --scan-delay 10s --script=vuln
- http_vuln: proxychains4 nmap -sT -Pn -p 80,443 -T1 --scan-delay 15s --script=http-vuln-static,http-vuln*
- ntp_info: sudo nmap -sU -p 123 --script=ntp-info (UDP — proxychains দ্বারা proxied নয়)

proxychains ও UDP/ICMP সীমাবদ্ধতা
---------------------------------
- `proxychains4` কেবল TCP কানেকশনগুলো proxied করতে পারে; UDP ও ICMP প্যাকেট proxied হবে না।
- Nmap-এর কিছু সেটিং/স্ক্রিপ্ট (যেমন `-sU` UDP scan, কিছু NSE scripts) TCP ছাড়া UDP/ICMP ব্যবহার করে—এই ক্ষেত্রে proxychains কার্যকর হবে না।
- UDP/ICMP কভারেজের জন্য সরাসরি `sudo nmap -sU ...` চালাতে হবে (শুধু অনুমোদিত লক্ষ্যবস্তুর উপর)।

আউটপুট লোকেশন ও লেনদেন নোট
-----------------------------
- প্রতিটি রান আউটপুট সংরক্ষণ করে: `scans/<target>/<UTC-timestamp>/` (উদাহরণ: `scans/example.com/20260904T123456Z/`).
- প্রতিটি রান `scan.log` (সমস্ত টার্মিনাল আউটপুট) এবং nmap এর `-oA` আউটপুট ফাইল রাখে।

- আমি কোনো WAF/CDN বাইপাস, IP স্পুফিং বা অননুমোদিত এভেশন অটোমেশন এখানে যোগ করিনি এবং ভবিষ্যতেও যোগ করব না।
