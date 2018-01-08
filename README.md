# Bookends Tools

[Bookends](http://www.sonnysoftware.com/) is an excellent bibliographic/research manager for macOS. This Alfred workflow curates 9 tools together in one interface to interact with Bookends and other apps. You can use Alfred keywords (*be…*) and/or bind your preferred key combination to trigger these directly. It has been designed for Alfred 3, and should keep itself up-to-date using [OneUpdater](https://github.com/vitorgalvao/alfred-workflows/tree/master/OneUpdater).

[Download it here…](https://raw.githubusercontent.com/iandol/bookends-tools/master/bookends-tools.alfredworkflow)

![Workflow screenshot](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/workflow.png)

Note: the tools donated with a 📄 use Applescript `System Events` to trigger keyboard bindings and this doesn't always trigger correctly... 

**key**: `📄: select some text in another app then trigger tool` — `🗄: select reference(s) within Bookends then trigger tool` — `⌨️: trigger tool and enter some text`  

1. **beidsearch** 📄 — Find a selected uniqueID in Bookends. For example, if you have a temporary citation like {Koffka, 1922, #6475} in your word-processor, double-click select the Bookends ID `6475`, then trigger this workflow and it will find the reference in Bookends for you.
2. **bebrowser** 📄 — Search selected text in Bookends browser. For the Pubmed interface you should select this manually in the bookends browser before triggering this tool. If the automatic paste into the search field fails, press ⌘V and ENTER to trigger the search.
3. **berefsearch** 📄 — Take some selected text like "(Doe et al., 2005)" citation, clean it up become "Doe 2005" and send it to Bookend's quick search. This is great because you can take a formatted ref in a text document and search for the first author/year, then quickly paste back (⌘Y for Scrivener) the Bookends style temporary citation in its place!
4. **bequickadd** 📄 — Take a text selected DOI / PMID / ISBN or JSTOR and use Quick Add (feature added in Bookends 13.0.3+) to quickly add this reference to the database.
5. **betoopml** 🗄 — Select multiple references within Bookends, then run this to create an OPML file which you can import into Scrivener or other OPML-aware tool. This will contain the abstract and notes which is very useful for research. It contains links back to the Bookends reference. You can configure the export path in the workflow variables (default Desktop/).
6.  **bescopus** 🗄 — Select a reference (with a DOI) in Bookends, then trigger this to search Scopus with the DOI.  It will return an inline results list for the Scopus entry AND the Cited-by page. Select an entry to go to that page. It will also append these Scopus URLs in the Notes field for future reference. You can enter your Scopus API key in the workflow variables. ![bescopus](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/5.png)
7. **betobibtex** ⌨️ — You enter the name of a Bookends static/smart group name and this will create a BibTeX bibliography file for those particular groups. Very useful for Pandoc and/or LaTeX workflows. You can optionally generate JSON. You can configure the export path in the workflow variables (default Desktop/). ![betobibtex](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/6.png)
8. **becite** ⌨️ — You enter an author name, and get an inline results list. You can then paste this as a temporary citation (⌘ pastes MMD style, ⌥ pastes Pandoc style).  ![becite](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/7.png)
9. **bebib** ⌨️ — You enter an author name, and get an inline results list. You can then paste this as a formatted reference (⌘ pastes MMD style, ⌥ pastes Pandoc style).
10. **betitle** ⌨️ — You enter a word in the title, and get an inline results list. You can then paste this as a temporary citation (⌘ pastes MMD style, ⌥ pastes Pandoc style).  ![betitle](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/betitle.png)

### Workflow variables

![variables](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/variables.png)  

There are several workflow variables which let you modify some of the functionality: 

* `appendScopusNotes` allows you to toggle the behaviour whereby the Scopus URLs are appended back to the Bookends reference note stream. 
* `BibTeXtoJSON` allows you to convert the BIB file to a JSON file, which at least for Pandoc-citeproc is much faster (~3X) to then process for the bibliography. 
* `protectBibTitles` makes titles in the BIB file {{ wrapped }} so the case is not changed in subsequent processing.
* `citationStyle` is the Bookends bibliographic style used by `bebib` when outputting the formatted reference.
* `exportPath` used by `betoopml` and `betobibtex`
* `scopusKey` your personal Scopus API key

### Scopus Info
For the Scopus search tool, ideally [you should register for your own Scopus API key](https://dev.elsevier.com/) (without it it will use the demo key which may or may not work) and enter it in the workflow variables. The Scopus URLs also benefit from an institutional subscription, otherwise you will see a preview (which still contains useful information). 

## Sources
Several of these very useful tools have been modified from the following sources:

### betoopml
Thanks to Dave Glogowski (dave83); [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=3882)

### betobibtex
Thanks and MIT copyright to Naupaka Zimmerman; [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=4246) | [Original Gist](https://gist.github.com/naupaka/3637da8f1449a279a79e643575a7c2e1)

### becite & bebib
Thanks to kseggleton; [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=4051)

### OneUpdater
Thanks to Vitor for his excellent update system for Alfred workflows: [OneUpdater](https://github.com/vitorgalvao/alfred-workflows/tree/master/OneUpdater)

