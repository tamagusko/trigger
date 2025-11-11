# Platform Usage Guide

This guide explains how to use the TRIGGER Open edX platform for creating courses, managing users, and delivering content.

## Table of Contents

1. [Getting Started](#getting-started)
2. [User Roles and Permissions](#user-roles-and-permissions)
3. [Creating Your First Course](#creating-your-first-course)
4. [Course Structure](#course-structure)
5. [Adding Content](#adding-content)
6. [Managing Users](#managing-users)
7. [Course Settings](#course-settings)
8. [Grading and Assessments](#grading-and-assessments)
9. [Analytics and Reporting](#analytics-and-reporting)
10. [Common Tasks](#common-tasks)

---

## Getting Started

### Accessing the Platform

**For Students (LMS - Learning Management System):**
- URL: `http://courses.trigger-project.eu` (production)
- URL: `http://local.overhang.io` (local development)

**For Instructors (Studio - Course Authoring):**
- URL: `http://studio.trigger-project.eu` (production)
- URL: `http://studio.local.overhang.io` (local development)

**For Administrators (Admin Panel):**
- URL: `http://courses.trigger-project.eu/admin` (production)
- URL: `http://local.overhang.io/admin` (local development)

### First Login

1. Navigate to the Studio URL
2. Click "Sign In" (top right)
3. Enter your credentials
4. If first time: Click "Register" and create an account

---

## User Roles and Permissions

### Student
- Enroll in courses
- View course content
- Submit assignments
- Participate in discussions
- View grades

### Staff
- Create and edit courses
- View student progress
- Grade assignments
- Manage course content
- Access course analytics

### Instructor
- All Staff permissions
- Manage course team
- Configure grading policies
- Export grades
- Send bulk emails

### Course Admin
- All Instructor permissions
- Delete courses
- Manage advanced settings

### Platform Administrator
- All permissions across all courses
- Manage users
- Configure platform settings
- Access Django admin panel

---

## Creating Your First Course

### Step 1: Access Studio

1. Go to your Studio URL
2. Sign in with your account
3. You should see the Studio dashboard

### Step 2: Create a New Course

1. Click the "+ New Course" button
2. Fill in the course information:

   **Course Name:** `Introduction to Sustainable Transportation`
   - This is the full name displayed to students

   **Organization:** `TRIGGER`
   - Your institution or project name

   **Course Number:** `TRIG101`
   - A unique identifier for the course

   **Course Run:** `2024`
   - The term or year (e.g., "2024", "Fall2024", "Q1-2024")

3. Click "Create"

**Understanding Course IDs:**
Your course will have an ID like: `TRIGGER+TRIG101+2024`

### Step 3: Configure Basic Settings

After creation, you'll be in your course. Configure these first:

1. Click "Settings" → "Schedule & Details"
2. Set important dates:
   - **Course Start Date:** When students can access content
   - **Course End Date:** When the course closes
   - **Enrollment Start:** When registration opens
   - **Enrollment End:** When registration closes

3. Add a course image:
   - Recommended size: 2120 x 1192 pixels
   - Format: JPG or PNG
   - Click "Upload Course Card Image"

4. Write a course description:
   - Brief overview (2-3 paragraphs)
   - What students will learn
   - Prerequisites (if any)

5. Click "Save Changes"

---

## Course Structure

Open edX courses are organized hierarchically:

```
Course
└── Sections (Weeks or Modules)
    └── Subsections (Lessons or Topics)
        └── Units (Individual pages)
            └── Components (Content blocks)
```

### Example Structure

```
Introduction to Sustainable Transportation (Course)
├── Week 1: Introduction to Transportation Systems
│   ├── Lesson 1.1: Overview of Transportation
│   │   ├── Unit: Video Lecture
│   │   ├── Unit: Reading Materials
│   │   └── Unit: Quiz
│   └── Lesson 1.2: Environmental Impact
│       ├── Unit: Case Study
│       └── Unit: Discussion
├── Week 2: Active Transportation
│   ├── Lesson 2.1: Cycling Infrastructure
│   └── Lesson 2.2: Pedestrian Planning
└── Final Exam
```

---

## Adding Content

### Creating Sections

1. From Course Outline, click "+ New Section"
2. Enter a name: "Week 1: Introduction"
3. Click "Add Section"
4. Set release date (when students can access it)

### Creating Subsections

1. Click "+ New Subsection" under a section
2. Enter a name: "Lesson 1.1: Course Overview"
3. Click "Add Subsection"
4. Configure:
   - **Release date:** When this subsection becomes available
   - **Due date:** For graded assignments
   - **Grading:** Select assignment type (Homework, Exam, etc.)

### Creating Units

1. Click "+ New Unit" under a subsection
2. Enter a name: "Welcome Video"
3. Click "Add Unit"
4. Add components (content blocks)

### Component Types

#### 1. Video Component

**To add a video:**

1. Click "Video" from component types
2. Click "Edit"
3. Upload video or provide YouTube URL
4. Options:
   - **Video URL:** YouTube, Vimeo, or direct link
   - **Transcript:** Upload .srt file or auto-generate
   - **Download:** Allow students to download
   - **Speed:** Enable speed controls

**Video Best Practices:**
- Keep videos under 10 minutes
- Add transcripts for accessibility
- Use high-quality audio
- Test playback before publishing

#### 2. Text/HTML Component

**To add text content:**

1. Click "Text" or "HTML"
2. Click "Edit"
3. Use the visual editor or HTML mode
4. Add:
   - Formatted text
   - Images
   - Links
   - Embedded content

**Formatting Tips:**
- Use headings for structure (H2, H3)
- Break text into short paragraphs
- Add bullet points for lists
- Include images to illustrate concepts

#### 3. Problem Component

**To add a problem (quiz question):**

1. Click "Problem"
2. Choose problem type:
   - **Multiple Choice:** One correct answer
   - **Checkbox:** Multiple correct answers
   - **Dropdown:** Select from menu
   - **Numerical Input:** Enter a number
   - **Text Input:** Enter text
   - **Math Expression:** Enter equations

**Example Multiple Choice:**

```
>>Which mode of transportation has the lowest carbon emissions per passenger-kilometer?<<

( ) Car
( ) Bus
(x) Bicycle
( ) Airplane

[explanation]
Bicycles produce zero direct emissions and are the most environmentally friendly option.
[explanation]
```

#### 4. Discussion Component

1. Click "Discussion"
2. Enter discussion topic
3. Students can post questions and replies

#### 5. Advanced Components

- **LTI (Learning Tools Interoperability):** Embed external tools
- **SCORM:** Import SCORM packages
- **Poll:** Quick surveys
- **Word Cloud:** Visual student responses
- **Drag and Drop:** Interactive exercises

---

## Managing Users

### Adding Course Staff

1. Go to "Settings" → "Course Team"
2. Click "Add a New Team Member"
3. Enter user's email
4. Select role:
   - **Staff:** Can edit course
   - **Admin:** Full course permissions
5. Click "Add User"

### Managing Student Enrollment

**View Enrolled Students:**

1. Go to "Instructor" tab (in LMS view)
2. Click "Membership"
3. See list of enrolled students

**Manually Enroll Students:**

1. In "Instructor" tab → "Membership"
2. Under "Batch Enrollment", enter email addresses (one per line)
3. Select:
   - **Enroll:** Add students
   - **Unenroll:** Remove students
4. Choose "Auto Enroll" or "Notify by email"
5. Click "Enroll"

**Download Student List:**

1. "Instructor" tab → "Data Download"
2. Click "Download profile information as a CSV"

### Creating User Accounts via Command Line

For bulk user creation:

```bash
# Create single user
tutor local do createuser --staff student1 student1@trigger.eu

# Import users from CSV
tutor local do importusers users.csv
```

**CSV format:**
```csv
email,username,name,password
student1@trigger.eu,student1,John Doe,password123
student2@trigger.eu,student2,Jane Smith,password456
```

---

## Course Settings

### General Settings

**Settings → Schedule & Details:**

- Course dates
- Course image
- Course description
- Introduction video
- Effort estimation
- Course language

### Grading Configuration

**Settings → Grading:**

1. **Assignment Types:**
   - Define types: Homework, Quiz, Exam, etc.
   - Set weights: Homework 30%, Exams 70%
   - Set drop policy: Drop lowest 1 score

2. **Passing Grade:**
   - Set minimum percentage to pass (default: 50%)

3. **Grace Period:**
   - Extra time after due date (e.g., 48 hours)

**Example Grading Configuration:**

| Assignment Type | Weight | # of Assignments | Drop Lowest |
|----------------|--------|------------------|-------------|
| Homework | 30% | 5 | 1 |
| Quizzes | 20% | 10 | 2 |
| Midterm | 20% | 1 | 0 |
| Final Exam | 30% | 1 | 0 |

### Advanced Settings

**Settings → Advanced Settings:**

Common settings to configure:

```json
{
  "display_name": "TRIGGER: Sustainable Transportation",
  "start": "2024-09-01T00:00:00Z",
  "enrollment_start": "2024-08-01T00:00:00Z",
  "language": "en",
  "show_calculator": true,
  "cert_html_view_enabled": true,
  "certificates_display_behavior": "end_with_date"
}
```

### Visibility Settings

**Settings → Pages & Resources:**

Control what students see:
- Discussion forums
- Progress page
- Course updates
- Textbooks
- Custom pages

---

## Grading and Assessments

### Creating Graded Assignments

1. Create a subsection
2. Click "Configure" (gear icon)
3. Set:
   - **Grade as:** Homework, Exam, etc.
   - **Due Date:** Deadline
   - **Show Results:** When students see answers
4. Add problem components

### Viewing Student Submissions

**Instructor Dashboard:**

1. View course in LMS (click "View Live")
2. Click "Instructor" tab
3. Navigate to:
   - **Student Admin:** View individual student data
   - **Data Download:** Export grades
   - **Analytics:** View course statistics

### Grading Strategies

**Auto-Graded:**
- Multiple choice questions
- Numerical problems
- Formula problems
- Automatically scored upon submission

**Manually Graded:**
- Essay questions
- File uploads
- Requires instructor review

### Exporting Grades

1. "Instructor" tab → "Data Download"
2. Click "Generate Grade Report"
3. Wait for email notification
4. Download CSV file
5. Contains: username, email, grade, assignment scores

---

## Analytics and Reporting

### Course Analytics

**Built-in Analytics:**

1. "Instructor" tab → "Analytics"
2. View:
   - Enrollment over time
   - Student engagement
   - Problem difficulty
   - Video completion rates

### Student Progress

**Individual Student:**

1. "Instructor" tab → "Student Admin"
2. Enter student email or username
3. View:
   - Course progress
   - Grade breakdown
   - Submission history
   - Time spent

**Bulk Progress:**

1. "Instructor" tab → "Data Download"
2. Click "Generate Problem Grade Report"
3. Download detailed CSV

### Insights Dashboard

If Tutor Insights plugin is enabled:

- Advanced analytics
- Custom reports
- Visualizations
- Learning outcomes tracking

---

## Common Tasks

### Publishing Course Content

**To make content visible to students:**

1. Ensure all units have content
2. Click "Publish" button (green) on each unit
3. Check that section/subsection release dates are set
4. In Course Outline, verify everything shows "Published"

### Hiding Content from Students

1. Click "Configure" on section/subsection
2. Toggle "Hide from students"
3. Use for drafts or future content

### Duplicating Content

1. Hover over unit/subsection
2. Click "Duplicate" icon
3. Edit the copy as needed
4. Useful for similar lessons or weeks

### Reorganizing Course Structure

1. Drag and drop sections/subsections/units
2. Reorder by clicking and dragging
3. Move to different sections

### Previewing as Student

1. Click "View Live" (top right in Studio)
2. See course as students see it
3. Or use "Preview" mode in Studio

### Sending Course Announcements

1. In LMS, click "Instructor" tab
2. Go to "Email"
3. Compose message
4. Select recipients:
   - All students
   - Specific cohorts
   - Staff and instructors
5. Click "Send Email"

### Creating Certificates

**Enable Certificates:**

1. "Settings" → "Advanced Settings"
2. Set `certificates_display_behavior` to `"end_with_date"`
3. Upload certificate template (requires admin access)

**Award Certificates:**

Automatically awarded when:
- Student passes course (>= passing grade)
- After course end date
- Certificates are enabled

### Managing Discussions

1. Enable forum in "Pages & Resources"
2. Add discussion components to units
3. Monitor via "Instructor" → "Forum Admin"
4. Moderate posts, pin important threads

### Cohorts (Groups)

**Create Student Groups:**

1. "Instructor" tab → "Cohorts"
2. Click "Add Cohort"
3. Name the cohort (e.g., "Group A")
4. Assign students manually or automatically
5. Use for:
   - Different discussion groups
   - A/B testing
   - Staggered deadlines

---

## Accessibility Best Practices

Ensure your course is accessible to all students:

### Videos
- Add captions/transcripts
- Provide descriptive audio when needed
- Avoid flashing content

### Text
- Use proper heading hierarchy
- Sufficient color contrast
- Don't rely solely on color for meaning

### Images
- Add alt text descriptions
- Make charts and graphs descriptive

### Assessments
- Allow extended time options
- Provide multiple attempt options
- Offer alternative formats

### Navigation
- Clear, logical structure
- Descriptive link text
- Keyboard navigable

---

## Tips for Effective Courses

### Content Design

1. **Chunk Content:** Break into 5-10 minute segments
2. **Mix Media:** Videos, text, interactives
3. **Active Learning:** Frequent practice problems
4. **Clear Objectives:** State learning goals upfront
5. **Progressive Difficulty:** Start easy, build complexity

### Student Engagement

1. **Regular Communication:** Weekly announcements
2. **Discussion Prompts:** Encourage peer interaction
3. **Timely Feedback:** Grade within 1 week
4. **Office Hours:** Live Q&A sessions
5. **Gamification:** Badges, leaderboards (via plugins)

### Course Maintenance

1. **Regular Updates:** Refresh content annually
2. **Monitor Analytics:** Identify problem areas
3. **Student Feedback:** End-of-course surveys
4. **Iterate:** Improve based on data
5. **Archive Old Runs:** Keep repository clean

---

## Troubleshooting

### Students Can't See Content

**Check:**
- Is content published? (green checkmark)
- Are section/subsection release dates in the past?
- Is the course started?
- Is student enrolled?

### Grades Not Appearing

**Check:**
- Is subsection marked as graded?
- Has student submitted answers?
- Are there any unsaved changes?
- Run grade recalculation: "Instructor" → "Student Admin" → "Rescore"

### Videos Not Playing

**Check:**
- Video URL is correct
- Video is public (not private on YouTube)
- Browser supports video format
- Firewall/proxy not blocking

### Can't Edit Course

**Check:**
- Do you have staff/admin role?
- Are you accessing Studio (not LMS)?
- Is your account activated?
- Try clearing browser cache

---

## Additional Resources

### Open edX Documentation
- Building a Course: https://edx.readthedocs.io/projects/open-edx-building-and-running-a-course/
- Video Guide: https://www.youtube.com/c/edXOnline

### Tutor Documentation
- Official Docs: https://docs.tutor.overhang.io/
- Plugin Catalog: https://overhang.io/tutor/plugins

### TRIGGER Resources
- Project Website: https://trigger-project.eu/
- Course Templates: [Add link to templates]
- Support Contact: [Add contact]

---

## Quick Reference: Keyboard Shortcuts

In Studio:

| Action | Shortcut |
|--------|----------|
| Save | `Ctrl/Cmd + S` |
| Publish | `Ctrl/Cmd + Shift + P` |
| Preview | `Ctrl/Cmd + Shift + V` |
| Search | `Ctrl/Cmd + F` |

---

**Previous:** [Deploy Guide](deploy.md) | **Next:** [Maintenance Guide](maintenance.md)
