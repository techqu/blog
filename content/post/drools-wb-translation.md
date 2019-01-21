---
title: "Drools Documentation"
date: 2019-01-19T13:18:56+08:00
lastmod: 2019-01-19T13:18:56+08:00
draft: true
keywords: []
description: ""
tags: []
categories: []
author: "瞿广"

# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: false
toc: true
autoCollapseToc: false
postMetaInFooter: true
hiddenFromHomePage: false
# You can also define another contentCopyright. e.g. contentCopyright: "This is another copyright."
contentCopyright: false
reward: false
mathjax: false
mathjaxEnableSingleDollar: false
mathjaxEnableAutoNumber: false

# You unlisted posts you might want not want the header or footer to show
hideHeaderAndFooter: false

# You can enable or disable out-of-date content warning for individual post.
# Comment this out to use the global config.
#enableOutdatedInfoWarning: false

flowchartDiagrams:
  enable: false
  options: ""

sequenceDiagrams: 
  enable: false
  options: ""

---


1. Introduction
2. KIE
3. Hybrid Reasoning
4. User Guide
5. Running
6. Rule Language Reference
7. Complex Event Processing
8. Decision Model and Notation (DMN)
9. Predictive Model Markup Language (PMML)
10. Experimental Features
11. Drools commands
12. CDI
13. Integration with Spring
14. Integration with Aries Blueprint
15. Android Integration
16. Apache Camel Integration
17. Drools Camel Server
18. Drools Workbench (General)
19. Authoring rule assets
20. Drools Workbench integration
21. Drools Workbench High Availability
22. KIE Execution Server
23. Examples
24. Release Notes


1. Introduction
1.1. Introduction
1.2. Getting Involved
1.2.1. Sign up to jboss.org
1.2.2. Sign the Contributor Agreement
1.2.3. Submitting issues via JIRA
1.2.4. Fork GitHub
1.2.5. Writing Tests
1.2.6. Commit with Correct Conventions
1.2.7. Submit Pull Requests
1.3. Installation and Setup (Core and IDE)
1.3.1. Installing and using
1.3.2. Building from source
1.3.3. Eclipse
2. KIE
2.1. Overview
2.1.1. Anatomy of Projects
2.1.2. Lifecycles
2.2. Build, Deploy, Utilize and Run
2.2.1. Introduction
2.2.2. Building
2.2.3. Deploying
2.2.4. Running
2.2.5. Installation and Deployment Cheat Sheets
2.2.6. Build, Deploy and Utilize Examples
2.3. Security
2.3.1. Security Manager
3. Hybrid Reasoning
3.1. Artificial Intelligence
3.1.1. A Little History
3.1.2. Knowledge Representation and Reasoning
3.1.3. Rules Engines and Production Rule Systems (PRS)
3.1.4. Hybrid Reasoning Systems (HRS)
3.1.5. Expert Systems
3.1.6. Recommended Reading
3.2. Rete Algorithm
3.3. ReteOO Algorithm
3.4. PHREAK Algorithm
4. User Guide
4.1. The Basics
4.1.1. Stateless KIE session
4.1.2. Stateful KIE session
4.1.3. Methods versus Rules
4.1.4. Cross Products
4.2. Execution Control
4.2.1. Agenda
4.2.2. Rule Matches and Conflict Sets.
4.3. Inference
4.3.1. Bus Pass Example
4.4. Truth Maintenance with Logical Objects
4.4.1. Overview
4.5. Logging
5. Running
5.1. KieRuntime
5.1.1. EntryPoint
5.1.2. RuleRuntime
5.1.3. StatefulRuleSession
5.2. Agenda
5.2.1. Conflict Resolution
5.2.2. AgendaGroup
5.2.3. ActivationGroup
5.2.4. RuleFlowGroup
5.3. Event Model
5.4. StatelessKieSession
5.4.1. Sequential Mode
5.5. Rule Execution Modes
5.5.1. Passive Mode
5.5.2. Active Mode
5.6. Propagation modes
5.7. Commands and the CommandExecutor
5.8. KieSessions pool
6. Rule Language Reference
6.1. Overview
6.1.1. A rule file
6.1.2. What makes a rule
6.2. Keywords
6.3. Comments
6.3.1. Single line comment
6.3.2. Multi-line comment
6.4. Error Messages
6.4.1. Message format
6.4.2. Error Messages Description
6.4.3. Other Messages
6.5. Package
6.5.1. import
6.5.2. global
6.6. Function
6.7. Type Declaration
6.7.1. Declaring New Types
6.7.2. Declaring Metadata
6.7.3. Declaring Metadata for Existing Types
6.7.4. Parametrized constructors for declared types
6.7.5. Non Typesafe Classes
6.7.6. Accessing Declared Types from the Application Code
6.7.7. Type Declaration 'extends'
6.8. Rule
6.8.1. Rule Attributes
6.8.2. Timers and Calendars
6.8.3. Left Hand Side (when) syntax
6.8.4. The Right Hand Side (then)
6.8.5. Conditional named consequences
6.8.6. A Note on Auto-boxing and Primitive Types
6.9. Query
6.10. Domain Specific Languages
6.10.1. When to Use a DSL
6.10.2. DSL Basics
6.10.3. Adding Constraints to Facts
6.10.4. Developing a DSL
6.10.5. DSL and DSLR Reference
7. Complex Event Processing
7.1. Complex Event Processing
7.2. Drools Fusion
7.3. Event Semantics
7.4. Event Processing Modes
7.4.1. Cloud Mode
7.4.2. Stream Mode
7.5. Session Clock
7.5.1. Available Clock Implementations
7.6. Sliding Windows
7.6.1. Sliding Time Windows
7.6.2. Sliding Length Windows
7.6.3. Window Declaration
7.7. Streams Support
7.7.1. Declaring and Using Entry Points
7.8. Memory Management for Events
7.8.1. Explicit expiration offset
7.8.2. Inferred expiration offset
7.9. Temporal Reasoning
7.9.1. Temporal Operators

<!--more-->
