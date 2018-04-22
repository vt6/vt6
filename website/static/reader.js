(function() {
  //when page is scrolled...
  var onscroll = function() {

    //...find to which heading the topmost element in the viewport belongs...
    var currentHeadingID = "";
    var contents = document.querySelectorAll("main > *");
    for (var idx = 0; idx < contents.length; idx++) { //not .forEach() because I need to `break`
      var contentNode = contents[idx];
      if (contentNode.id !== "") {
        currentHeadingID = contentNode.id;
      }
      if (contentNode.offsetTop > window.pageYOffset) {
        break;
      }
    }

    //...highlight that heading in the TOC
    var tocLinks = document.querySelectorAll("aside a");
    var expectedHref = "#" + currentHeadingID;
    var tocOpenerCaption = "Table of contents";
    Array.prototype.forEach.call(tocLinks, function(link) {
      if (link.getAttribute("href") == expectedHref) {
        link.setAttribute("class", "scrolled");
        tocOpenerCaption = link.innerText;
      } else {
        link.setAttribute("class", "");
      }
    });

    //...mention the current heading in the TOC opener (only visible on mobile)
    var tocOpener = document.querySelector("aside a#toc-open");
    tocOpener.innerHTML = tocOpenerCaption;
  };

  window.onscroll = onscroll;
  onscroll();
})();
