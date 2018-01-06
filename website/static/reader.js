(function() {
  var tocOffsetTop = document.querySelector("aside").offsetTop;

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
    Array.prototype.forEach.call(tocLinks, function(link) {
      if (link.getAttribute("href") == expectedHref) {
        link.setAttribute("class", "scrolled");
      } else {
        link.setAttribute("class", "");
      }
    });

    //also, emulate "position:sticky" for the TOC container (cannot use
    //"position:sticky" directly because element is absolutely rather than
    //relatively positioned)
    var aside = document.querySelector("aside");
    if (window.pageYOffset > tocOffsetTop) {
      aside.style.top = "0px";
    } else {
      aside.style.top = (tocOffsetTop - window.pageYOffset) + "px";
    }
    //TODO: disable this ^ on narrow screens, where <aside> is not placed as implied by this code
  };

  window.onscroll = onscroll;
  onscroll();
})();
