# ZeroIPSpoof

![project banner](./ChatGPT%20Image%20Jun%202%2C%202026%2C%2001_08_01%20PM.jpg)

সংক্ষেপে
---------
ZeroIPSpoof একটি সাহায্যকারী রিপোজিটরি যা অনুমোদিত (authorized) পেন-টেস্টিং ও বাগ-বাউন্টি ওয়ার্কফ্লো সুবিধা দেয়। এটি কেবল টুল ইনস্টলেশন ও সেফ-অটোমেশন স্ক্রিপ্ট সরবরাহ করে — এটি কোনো WAF/CDN বাইপাস, IP স্পুফিং বা অননুমোদিত এভেশন অটোমেশন সরবরাহ করে না।

সতর্কতা ও লিগ্যাল নোট (অবশ্যক)
-------------------------------
- এই প্রজেক্টের সব স্ক্রিপ্ট **শুধুমাত্র** সেইসব লক্ষ্যবস্তুতে ব্যবহার করা যাবে যেগুলোর জন্য আপনার কাছে **স্পষ্ট লিখিত অনুমতি (explicit written permission)** আছে।
- অ-অনুমোদিত স্ক্যান বা সার্ভিসের উপর পরীক্ষা আইনগত ও নৈতিকভাবে অপরাধ হতে পারে।
- সব এনগেজমেন্টে আপনার রুলস অফ এনগেজমেন্ট (Rules of Engagement) ও অনুমোদনের কপি সংরক্ষণ করুন।

ইনস্টলেশন
-----------
রিপো মূল ডাইরেক্টরিতে থাকা `install.sh` স্ক্রিপ্টটি Debian/Ubuntu/Kali-ভিত্তিক সিস্টেমে সাধারণ পেন-টেস্ট টুলগুলো ইনস্টল করবে। চালানোর উদাহরণ:

```bash
chmod +x install.sh
./install.sh

Install স্ক্রিপ্টটি চালানোর সময় এটি আপনাকে নিশ্চিতকরণ (Type YES) চাইবে যে আপনার কাছে লিখিত অনুমতি আছে — না থাকলে ইনস্টল বন্ধ হয়ে যাবে।

Run Instructions (Scan Runner)
এই রিপোতে একটি নিরাপদ স্ক্যান রানার স্ক্রিপ্ট আছে: tools/run_scans.sh। এটি অনুমোদিত এনগেজমেন্টে প্রি-কনফিগার করা nmap(proxychains) কমান্ডগুলো চালাতে ব্যবহার করা যাবে।

উদাহরণ:
chmod +x tools/run_scans.sh
# quick TCP scan using proxychains and an NSE script named "vuln"
./tools/run_scans.sh --target example.com --mode quick_tcp --script vuln

# HTTP focused vulnerability scan
./tools/run_scans.sh --target example.com --mode http_vuln

# NTP (UDP) info (requires sudo) — নোট: UDP proxied নয়
sudo ./tools/run_scans.sh --target 1.2.3.4 --mode ntp_info

# Dry-run (only prints commands)
./tools/run_scans.sh --target example.com --mode quick_tcp --script vuln --dry-run

# CONTRIBUTING

ধন্যবাদ! আপনি যদি এই রিপোতে কন্ট্রিবিউট করতে চান, অনুগ্রহ করে নিচের ধাপগুলো অনুসরণ করুন:

1. ইস্যু খুলুন (Issue)
   - নতুন ফিচার প্রস্তাব, বাগ রিপোর্ট বা ডকুমেন্টেশন ইস্যু আগে একটি Issue খুলুন এবং কিভাবে পরিবর্তন করা হচ্ছে সংক্ষেপে ব্যাখ্যা করুন।

2. Fork এবং Branch
   - এই রিপো Fork করুন এবং নতুন ফিচারের জন্য একটি নতুন ব্রাঞ্চ তৈরি করুন: `git checkout -b feature/your-feature`

3. কমিট বার্তা
   - পরিষ্কার, সংক্ষিপ্ত ও সম্পর্কিত কমিট মেসেজ ব্যবহার করুন।

4. Pull Request
   - একটি PR তৈরি করুন এবং আপনার পরিবর্তনের বিবরণ দিন; যদি এটি কোড চেঞ্জ হয় তবে কিভাবে লোকালভাবে টেস্ট করা হয়েছে তা উল্লেখ করুন।

5. নিরাপত্তা ও রেসপন্সিবিলিটি
   - কোনো টুল বা স্ক্রিপ্ট এনগেজমেন্টে প্রয়োগ করার আগে নিশ্চিত করুন যে আপনার কাছে লিখিত অনুমতি আছে।
   - কোনো কোড যেখানে স্বয়ংক্রিয়ভাবে এভেশান, স্পুফিং বা বাইপাসিং সংক্রান্ত কার্যকারিতা যোগ করবে তা এই রিপোতে merge করা যাবে না। যদি আপনার বৈধ প্রয়োজন থাকে, আগে maintainers-কে যোগাযোগ করুন এবং সময়মত ROE (Rules of Engagement) প্রদান করুন।

# RULES_OF_ENGAGEMENT (Template)

Use this template to record and track authorization for any engagement that uses tools from this repository.

1. Engagement identification
   - Project / Program Name:
   - Client / Target Organization:
   - Primary Contact (name, email, phone):

2. Authorization
   - Authorized testers (names, roles):
   - Authorization document reference (attach or provide link):
   - Authorization start date/time (UTC):
   - Authorization end date/time (UTC):

3. Scope
   - In-scope assets (domains, IP ranges, hosts, cloud assets):
   - Explicitly out-of-scope assets:

4. Allowed tests
   - Passive discovery: Yes/No
   - Active scanning (nmap, masscan): Yes/No
   - Denial-of-service testing: Yes/No (usually NO)
   - Social engineering / phishing: Yes/No
   - Exploitation & post-exploit: Yes/No (detail approvals)

5. Constraints & Safe-guards
   - Rate limits (requests/sec or max concurrent scans):
   - Time windows for testing (UTC):
   - Emergency stop criteria (what to do if an incident occurs):
   - Point of contact for outages / incidents (24/7 if required):

6. Logging & Data handling
   - Where will logs be stored?
   - Data retention period:
   - Sensitive data handling instructions:

7. Reporting
   - Format and timeline for interim and final reports:

8. Signatures
   - Authorized signatory name & role:
   - Signature (or electronic approval reference):
   - Date:


IMPORTANT: Keep this document with engagement records and attach the authorization to any technical reports or bug bounty submissions.
