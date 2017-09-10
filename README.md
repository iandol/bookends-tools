# Bookends Tools

[Bookends](http://www.sonnysoftware.com/) is an excellent bibliographic/research manager for macOS. This Alfred workflow curates 8 tools together in one interface to interact with Bookends and other apps. You can use Alfred keywords (*be…*) and/or bind your preferred key combination to trigger these directly.

[Download it here…](https://raw.githubusercontent.com/iandol/bookends-tools/master/bookends-tools.alfredworkflow)

![Workflow screenshot](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/workflow.png)

**key**: `📄: select some text in another app then trigger tool` — `🗄: select reference(s) within Bookends then trigger tool` — `⌨️: trigger tool and enter some text`  

1. **beidsearch** 📄 — Find a selected uniqueID in Bookends. For example, if you have a temporary citation like {Koffka, 1922, #6475} in your word-processor, double-click select the Bookends ID `6475`, then trigger this workflow and it will find the reference in Bookends for you.
2. **bebrowser** 📄 — Search selected text in Bookends Pubmed browser. This requires that you have the Pubmed interface selected in the bookends browser. Also sometimes the paste into the search field fails, in which case you need to manually press ⌘V and ⌅ (enter).
3. **berefsearch** 📄 — Take selected i.e. "(Doe et al., 2005)" citation, clean it up "Doe 2005" and send it to Bookend's quick search.
4. **betoopml** 🗄 — Select references within Bookends, then run this to create an OPML file which you can import into Scrivener or other OPML-aware tool. You can configure the export path in the workflow variables (default Desktop/).
5.  **bescopus** 🗄 — Select a reference (with a DOI) in Bookends, then trigger this and it will search Scopus with the DOI, and return an inline results list for the Scopus entry AND the Cited-by page. Select an entry to go to that page. It will also append these Scopus URLs in the Notes field for future reference. You can enter your Scopus API key in the workflow variables. Enter the export path in the workflow variables (default ~/Desktop/). ![bescopus](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/5.png)
6. **betobibtex** ⌨️ — You enter the name of a Bookends static/smart group name and this will create a BibTeX bibliography file for those particular groups. Very useful for Pandoc and/or LaTeX workflows. You can configure the export path in the workflow variables (default Desktop/). ![betobibtex](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/6.png)
7. **becite** ⌨️ — You enter an author name, and get an inline results list, you can then paste this as a temporary citation (⌘ pastes MMD style, ⌥ pastes Pandoc style).  ![becite](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/7.png)
8. **bebib** ⌨️ — You enter an author name, and get an inline results list, you can then paste as a formatted reference (⌘ pastes MMD style, ⌥ pastes Pandoc style).

### Workflow variables

![variables](https://raw.githubusercontent.com/iandol/bookends-tools/master/images/variables.png)  

There are several workflow variables which let you modify some of the functionality. For example, `BibTeXtoJSON` allows you to save as a JSON file rather than a BIB file, which at least for Pandoc-citeproc is much faster (~3X) to parse. `appendScopusNotes` allows you to toggle the behaviour whereby the Scopus URLs are appended back to the Bookends reference note stream.

### Scopus Info
For the Scopus search tool, ideally [you should register for your own Scopus API key](https://dev.elsevier.com/) (without it it will use the demo key which may or may not work) and enter it in the workflow variables. The Scopus URLs also benefit from an institutional subscription, otherwise you will see a preview (which still contains useful information). 

## Sources
Several of these very useful tools come from the following sources:

### betoopml
Thanks to Dave Glogowski (dave83); [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=3882)

### betobibtex
Thanks and MIT copyright to Naupaka Zimmerman; [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=4246) | [Original Gist](https://gist.github.com/naupaka/3637da8f1449a279a79e643575a7c2e1)

### becite & bebib
Thanks to kseggleton; [Bookends forum thread](https://www.sonnysoftware.com/phpBB3/viewtopic.php?f=6&t=4051)

