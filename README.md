https://www.reddit.com/r/mining/comments/ipc4c0/surpac_discussionhelp_forum/

*Sometimes the blast boundaries change due to the nature of mining and I was looking into a way to create a macro which would edit the description of a point in a string file in relation to a blast string polygon it is planned within from another stting file.*

What this does:

The file *shot_numbers.tcl* assumes you have two files:

1. The first file contains blast outlines where each blast has it's own unique **string** number. An example file is included called *outlines_1.str*. 
2. The second file contains blast holes as collars I guess, and it doesn't matter what the string number of those are. A simple example is included as *pts1.str*

What it does: 

You find the files, then it basically goes over every point and checks if it lies inside an outline string or not; if it does then it writes the outline string number in the D1 field. Then it saves the points file as a new file called *test1.str*. This is essentially a proof of concept and should be modified as required for actual usage.

If your files don't have IDs (the number on the end) this will need minor modification because it won't work as-is. 
