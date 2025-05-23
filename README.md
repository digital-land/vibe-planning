# Vibe planning

* How could consulting on a local plan be different in the age of AI?
* Could we have a consulation which is about offering solutions to meeting the housing need?
* Could the consultation process allow people to upvote, or build on other people's ideas?

Can we enable "vibe planning"?

# Demo roadmap
* a free text box below "Explain why you chose this plan"
* Link / text box: "Work with our AI to generate your proposal"
* "Submit your proposal" button
* Content: Submitting your plan will add it to the list of propsals created by the public 
* Link to "see modify and support proposals from our planners and the rest of the community"
* Radio button for mode of selecting cells:
   * Housing
   * Commercial
   * Undeveloped
* Histogram of total area (built-up, green-belt, released for housing) updated as you select cells

# Data roadmap

* <s>build grid for more LPAs</s>
* <s>add area of green-belt in each cell</s>
* <s>build data for all of the LPAs surrounding Leeds</s>
* add [built-up areas](https://www.planning.data.gov.uk/map/?dataset=built-up-area)
* find target housing numbers
* connectivity of each cell to an existing school

https://digital-land.github.io/vibe-planning/debug.html

# Rebuilding the data

We recommend working in [virtual environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/) before installing the python [requirements](requirements.txt), [makerules](https://github.com/digital-land/makerules) and other dependencies. Requires Make v4.0 or above.

    $ make init
    $ make

# Licence

The software in this project is open source and covered by the [LICENSE](LICENSE) file.

Individual datasets copied into this repository may have specific copyright and licensing, otherwise all content and data in this repository is
[© Crown copyright](http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/copyright-and-re-use/crown-copyright/)
and available under the terms of the [Open Government 3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
