simple-search
=============

A barebones frontend to connect to a Solr Instance

Why is it called 'simple search'?
---------------------------------

Because this is designed to intentionally be as simple and minimalistic as possible.  This front end is given to you, and because it's given, it is limited.

However, even though it's minimalistic and simple, it still does a great job of demonstrating how any kind of front end website connects with Solr.  Look carefully at the code, and try to expand off of what is already present.

How it works in a nutshell
--------------------------

1. Set up HTML templates
2. Fill templates with data from search queries

That literally sums up just how easy it is.

The library that's used for templating is jQuery.  Here's what the search result template looks like:

    <div class="template result">
      <div class="title">
        <a href="">
          <h3></h3>
        </a>
      </div>
      <div class="url"></div>
      <div class="content"></div>
    </div>
      
jQuery then takes the JSON back from an AJAX request, and just fills the various parts of this template in, then inserts it into the DOM.  There's a bit more going on, but that's the general idea.  This approach scales well, and is also used in most javascript frameworks, like [Angular](https://angularjs.org/), [Ember](http://emberjs.com/), and [Meteor](https://www.meteor.com/) (all of which are great to learn and possibly use for your front end).

How to expand simple-search
---------------------------

To start modifying simple search, just fork it and begin modifying the code.

As I stated before, this is a minimalistic search engine, and there are an infinite amount of features that you could add to improve this.  Here are some various features that could easily be added by taking advantage of Solr:

- [Spell checking](https://cwiki.apache.org/confluence/display/solr/Spell+Checking)
- [Suggested Results](https://cwiki.apache.org/confluence/display/solr/Suggester)
- [Hit highlighting](https://cwiki.apache.org/confluence/display/solr/Highlighting)
- [EdisMax Features](http://wiki.apache.org/solr/ExtendedDisMax)
- [Geospatial search](https://cwiki.apache.org/confluence/display/solr/Spatial+Search) (for the brave only)

Outside of Solr, there's plent of other things that you could also add to improve your site:

- [A CSS framework](http://mashable.com/2013/04/26/css-boilerplates-frameworks/) like [Bootstrap](http://getbootstrap.com/)
- [Animations](http://www.css3maker.com/css3-animation.html) (Preferably using CSS3)
- [HTML5 Stuff](http://www.html5rocks.com/en/)
- A more aesthetic interface
- WebGL (again, for the brave)
- [Responsive interface](http://designmodo.com/responsive-design-examples/)

Of course, there's no limit to what you can do, and everything here is just a suggestion.  Do what you want, and don't be afraid to experiment with something new!
