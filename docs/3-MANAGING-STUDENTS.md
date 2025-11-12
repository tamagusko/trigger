# Managing Students

How to add students and track their progress.

## Creating Student Accounts

### Method 1: Let Students Register Themselves

1. Give students this link: http://local.overhang.io/register
2. They create their own account
3. They can then enroll in your course

### Method 2: Create Accounts Manually (Mac/Linux)

Open Terminal and run:

```bash
# Create one student
tutor local do createuser student student@example.com
```

### Method 2: Create Accounts Manually (Windows)

Open Git Bash and run:

```bash
# Create one student
tutor local do createuser student student@example.com
```

**Note:** The system will ask you to set a password for the student.

---

## Enrolling Students in Your Course

### From the Platform

1. Go to your course in the regular view (not Studio)
   - Visit: http://local.overhang.io
2. Find your course and open it
3. Click the **"Instructor"** tab at the top
4. Click **"Membership"**
5. Under "Batch Enrollment", type student email addresses (one per line)
6. Click **"Enroll"**

---

## Checking Student Progress

### View Individual Student

1. Go to your course on http://local.overhang.io
2. Click **"Instructor"** tab
3. Click **"Student Admin"**
4. Enter student's email or username
5. Click **"Student Progress Page"**

You'll see:
- Which lessons they've completed
- Their quiz scores
- Time spent in the course

### Download All Grades

1. Click **"Instructor"** tab
2. Click **"Data Download"**
3. Click **"Generate Grade Report"**
4. Wait a few minutes
5. Click **"Download"** to get a spreadsheet with all student grades

---

## Adding Teaching Assistants

1. In Studio, click **"Settings"** → **"Course Team"**
2. Click **"Add a New Team Member"**
3. Enter their email address
4. Choose role:
   - **Staff** - Can edit course content
   - **Admin** - Can edit content AND manage students
5. Click **"Add User"**

---

## Sending Messages to Students

### Send an Announcement

1. Go to course on http://local.overhang.io
2. Click **"Instructor"** tab
3. Click **"Email"**
4. Write your message
5. Select who receives it:
   - "Myself" (for testing)
   - "Staff and Instructors"
   - "All Students"
6. Click **"Send Email"**

---

## Common Questions

**How do I remove a student?**
1. Go to **"Instructor"** → **"Membership"**
2. Under "Batch Enrollment", enter their email
3. Select **"Unenroll"** instead of "Enroll"
4. Click the button

**Can students re-take quizzes?**
Yes, by default. You can change this in the quiz settings.

**How do I see who's active?**
Click **"Instructor"** → **"Analytics"** to see enrollment and activity graphs.

**How do I reset a student's progress?**
1. Go to **"Instructor"** → **"Student Admin"**
2. Enter student email
3. Click **"Reset Student Attempts"**

---

**Next:** Read [4-DEPLOYMENT.md](4-DEPLOYMENT.md) if you want to publish online for real students.
