// Copyright (c) 2021 Universitäts- und Landesbibliothek Sachsen-Anhalt
// ******Achtung********
// Die Links 'Suche' und 'Home' erscheinen nur, wenn ein (leeres) Menue im Hauptbereich angelegt wird!

var lang = $('html').attr('lang');
var home= document.createElement("li");
var homelink = document.createElement("a");
homelink.href="/"
homelink.title = "Home"
homelink.innerText="Home"
$(homelink).appendTo($(home))
$(home).appendTo("#navigationPrimary")

var search = document.createElement("li");
var searchlink = document.createElement("a");
searchlink.title = "Suche"
searchlink.href="/index/search/"
var searchlabel = "Suche"
if (lang.includes('en')) {
 searchlabel = 'Search'
}
searchlink.title = searchlabel
searchlink.innerText=searchlabel
$(searchlink).appendTo($(search))
$(search).appendTo("#navigationPrimary")
var copyimg = $(".pkp_brand_footer a img")
copyimg.attr("src", "https://licensebuttons.net/l/by-sa/3.0/80x15.png")
copyimg.css({"padding-top":"3px","display":"block"})
copyimg.attr("title", "Alle Beiträge auf dieser Domain werden unter der Creative Commons Lizenz CC BY SA publiziert.")
$(".pkp_brand_footer").append("<a style='padding-left:10px;max-width:200px' href='https://pkp.sfu.ca/ojs/' >&copy; Journal System by PKP</a>")

// If query action --> append query string to all matches
$('.obj_article_summary a').each(function() {
    $(this).attr('href', this.href + location.search);
});

// Banner image should link back to entry page
$('.pkp_site_name .is_img').attr('href', '/')