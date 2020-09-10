
######################################################################
#
# Macro Name    : shot_numbers
#
# Description   : for u/LostBookOfMatches from u/rusty_d
#
######################################################################

# creates UI

set form {
  GuidoForm AssignNumbers {
    -default_buttons
    -label "Assign blast number to blastholes from outlines"

    GuidoFileBrowserField bl {
          -label "Locate Blast Outline File"
          -display_length 10
          -max_length 252
          -file_mask "*.str"
          -format none
          -translate none
          -start_dir .
          -null false
          -link blid
          }
          GuidoField blid {
          -label "Outline File ID"
          -display_length 5
          -format real_8
          -null false
          }

    GuidoFileBrowserField bp {
          -label "Locate Blast Points File"
          -display_length 10
          -max_length 252
          -file_mask "*.str"
          -format none
          -translate none
          -start_dir .
          -null false
          -link bpid
          }
          GuidoField bpid {
          -label "Point File ID"
          -display_length 5
          -format real_8
          -null false
          }
    }
}

set status [SclCreateGuidoForm form_handle $form {}]

$form_handle SclRun {}	

if {"$_status" == "cancel"} then {
   puts " User Pressed Cancel"
   return
} else {


puts "Processing...."

# get filenames
append bl_file $bl $blid ".str"
append bp_file $bp $bpid ".str"

# open BL file into graphics
set status [ SclFunction "RECALL ANY FILE" {
  file="$bl_file"
  mode="openInNewLayer"
}]

# load the points into a temporary layer
SclCreateSwa PointHandle "temporary_point_layer"; # create a temporary layer
$PointHandle SclSwaOpenFile "$bp_file"; # load the points into the layer
$PointHandle SclGetStrings PointStringsHandle

# iterate over the outlines
SclGetActiveViewport ViewportHandle
$ViewportHandle SclGetActiveLayer SwaHandle
$SwaHandle SclGetStrings StringsHandle
set count [$StringsHandle SclCountItems]
# puts "There are $count different strings in the outlines file"
for {set i 0} {$i < $count} {incr i} {
  $StringsHandle SclGetItem StringHandle $i
  set stringNumber [$StringHandle SclGetId]
  puts "Working on outline number: $stringNumber"

# now iterate over the points and see if each point is inside the string or not
  $PointStringsHandle SclIterateLast StringsIterator
    while {[$StringsIterator SclIteratePrev PointStringHandle] == $SCL_TRUE} {
    $PointStringHandle SclIterateLast StringIterator
        while {[$StringIterator SclIteratePrev PointSegmentHandle] ==  $SCL_TRUE} {
            $PointSegmentHandle SclIterateLast SegmentIterator
            while {[$SegmentIterator SclIteratePrev PointPointHandle] == $SCL_TRUE} {
                set x [$PointPointHandle SclGetValueByName x]
                set y [$PointPointHandle SclGetValueByName y]
                set val [$PointPointHandle SclGetValueByName d1]
                set inside [$StringHandle SclInside $x $y]
                # inside result can either be 1 (inside), -1 (on the exact boundary) or 0 (outside)
                # we shouldn't have too many that are on the exact boundary (segment snapped to drillhole), but
                # if we do we will treat them as inside
                if {$inside != 0} {
                $PointPointHandle SclSetValueByName d1 $stringNumber
                }
            }
        }
    }
}

# save the output to some new file with this boilerplate from the help manual
set today [clock format [clock seconds] -format "%d %b %Y"]
set options "header=test, $today, Test of SclSwaSaveStringFile, mystyles.ssi|axis=0, 0.0, 0.0, 0.0, 100.0, 100.0, 0.0|binary=on"
if {[catch {$PointHandle SclSwaSaveStringFile test1.str "$options"}] != 0} {
  # this is how we trap for errors
  puts "Error saving active layer to test1.str"
} else {
  # save was successful
  puts "active layer saved to test1.str"
}

# cleanup
set status [ SclFunction "EXIT GRAPHICS" {} ]
puts "Processing complete."

}