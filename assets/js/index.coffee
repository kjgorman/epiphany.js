$(document).ready ->
    $(".footer").hover ->
        $(this).animate {"font-size":"1.0em"}
    , ->
        $(this).animate {"font-size":"0.5em"}
    
