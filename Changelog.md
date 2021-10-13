# Changelog
* 1.3.9 — allow ⇧⌃ [shift]+[control] to copy the `bookends://` link as text in **becite**, **betitle** and **beall**.
* 1.3.8.1 — bugfix for attachments
* 1.3.8 — minor tweak to fix error if both author and editor fields are empty for **beall**, **becite** and **betitle**.
1.3.7 — **becite**/**betitle**/**beall**/**bebib**: allow ⌘⌥ [command][option] to open an attached PDF directly.
* 1.3.6 — **bebib**: make sure this uses the `citeUsesRTF` variable so you can choose RTF or plain text output. There is also a new tool **beconvert** which is only useful if you want to convert author-date formatted citations to temp bibtex key intext citations.
* 1.3.5 — **betobibtex**: Allow using a customised BibTeX formatter, default is the builtin BibTeX, but for example you can make a modified format removing address and abstract that makes export faster and the resultant files much smaller.
* 1.3.4 — **bequickadd**: use the new applescript command rather than GUI scripting; **betobibtex**: if JSON conversion is empty (perhaps an empty citekey or other problem), warn the user and don't delete the source bibtex file.
* 1.3.3 — **bescopus**: update applescript with better error checking and working round a proxy open-uri issue in ruby, added an environment variable `scopusBaseURL` to specify a replacement base url prefix, if for e.g. you access through a proxy.
* 1.3.2 — **botoopml**: fix script
* 1.3.1 — **bequick**: don't "hide" bookends, rather refocus previous app…
* 1.3.0 — **bequick**: small tweak to hide bookends after triggering "quick-add", giving focus back to browser.
* 1.2.9 — add a new workflow variable `tempCitationStyle` that sets the default temporary citation format for **becite** / **betitle** / **beall**. When unset it will be the Bookends standard `{author,year,#id}`, but you can set the variable to `Pandoc` / `MMD` / `LaTeX` to paste the citation in a different format (`[@key]` / `[#key]` / `\\cite[]{key}`). Also if the authors field is empty for a reference, we now try to use editor names instead in the Alfred results list.
* 1.2.8 — add phrase search, so for example 'optical coherence' 2013 will find papers that use that exact phrase rather than before where optical and coherence were searched irrespective of their location.
* 1.2.7 — handle empty author fields better.
* 1.2.6 - **betitle** and **beall** broke in the last commit, fix them here...
* 1.2.5 — **becite**/**betitle**/**beall** first AND last author names with initials are now shown, and if an attachment is present you can Quicklook it directly from Alfred without losing focus (press shift or ⌘Y)!
* 1.2.4 — **becite**/**betitle**/**beall** now show if a reference has an attachment, and for BE13 users use the new applescript events that are slightly more efficienct.
* 1.2.3 — small change to open the attachment when you use **becite** with [fn].
* 1.2.2 — update the Scopus search tool to the newest API changes (https by default and httpAccept is required)
* 1.2.1 — rewrote the **becite**, **bebib** and **betitle** tools to perform a mutliple item search (i.e author1 + author2) and you can add an optional YEAR to refine the search. So for example [Zipser Lamme 1998] searches for references by authors (or editors) Zipser and Lamme published in 1998. Also optimised the search code (rewritten in Ruby) so now it takes much less time for large results sets. Add a new [beall] tool to search in all fields. For **becite**/**betitle**/**beall** you can now use SHIFT to open ref directly in Bookends.
* 1.2.0 — beta release
* 1.1.1 — **becite** handles newlines in dates better...
* 1.1.0 — option to use RTF for **becite**/**betitle** temporary citations to enable bookends links copied to RTF comments/annotation aware apps like Scrivener. Added Workflow env variables citeUsesRTF to enable/disable this feature. Note it cannot match your font on paste of RTF...
* 1.0.9 - add quick add tool that allows you to select a DOI/PMID/ISBN/JSTOR in any app and use the new quick add tool in BE >13.0.3
* 1.0.8 — allow author or editor search for **becite**, better chinese fix
* 1.0.7 — try to get search for chinese authors to work
* 1.0.6 — add **betitle** that searches within the reference title for a word.
* 1.0.5 — add ⌥ to **bebib** to paste pandoc footnote format. **bebib** formatted ref now pastes in the target app. add environment variable to control the bibliography format for **bebib**.