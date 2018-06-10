cBathy Contribution Guidlines
=============================

If you're here, that means you're considering contributing to the development of [cBathy](https://doi.org/10.1002/jgrc.20199).
That's exciting and we're glad you're here!  This is an open and welcoming community but to keep some semblance of order, 
a few rules and suggestions for contributions.  :) 

These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

Please see the [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md) 


Git Development Conventions:
----------------------------
The rules for new feature enhancement is laid out below:

- The main branch for releases is `master`.  Each new release is marked with a tag for release.

- The main development branch is `development`.  

- Each new feature is developed on a `[new feature]` branch. 

- To contribute:
  - create a topic branch (`[new feature]`) from where you want to base your work.
  - This is usually the `development` branch.
  - Only target `release` branches if you are certain your fix must be on that branch.
  - Please avoid working directly on the `master` branch.
  
- Make commits of logical and atomic units.

- Make sure your commit messages are in the proper format.  If they identify a established issue please identify in your commit

- Make sure you have added the necessary tests for your changes or bug fixes.

Submit a [pull request!](https://help.github.com/articles/creating-a-pull-request/)

At this point you're waiting on us. We like to at least comment on pull requests within three to five business days (and, typically, one business day). We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

- Write tests.
- Follow our style guide.
- Write a good commit message.
 
**FORKS**
if you're not comfortable developing in the main repository, you can try forking!  We do ask that when you've made developments
that do still submit a pull request from your forked repository back to the main (upstream) repository. 

Testing Proceedure 
------------------
Each new release (version) is merged after extensive testing proceedures listed below.  
> Lay out testing proceedure here 
(We would love for someone to develop automated testing environemnt)

**Merging from `[new feature]` to `development` for enhancement** 
We currently do not have an automated testing environment for each pull request.  There are manual tests that are run when
merging from `[new feature]` to `development`.  

**Merging from `development` to `master` for new release** 
New releases need to be throughly vetted ... list proceedure here

TODOs 
-----
We have a list of contributions that people who are new to the community (or seasoned verterans) 
Currently they're in the issues tab, but if people have other suggestions we're open to suggestions 
We've tried to create tags that help users identify contributions that they can make based on their comfortablity with the status

Comments Required
-----------------
Please comment code thoroughly and professionally

Variable name convention
------------------------
please use explicit variable names so others can understand the variable name (don't be worried about variable name length)
it's better to have a variable name like `significantWaveHeight` instead of `H`.  It is more clear. 

Please see established coding conventions from the WIKI page that include variable name convention
https://github.com/Coastal-Imaging-Research-Network/Forum-Wiki/wiki/Coding-Standards

> _establish variable name convention (camel humps? underscores? others?)_

Changing Role
-------------
If you would like to change your role within the repository submit a request [here](https://goo.gl/forms/7VX5isIpHrV1jSlH2)

please be sure to use a valid GitHub user name.
