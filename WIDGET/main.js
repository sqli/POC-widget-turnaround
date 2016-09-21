'use strict';
(function () {

    var loadCss = function(applicationName){
        var head  = document.getElementsByTagName('head')[0];
        var link  = document.createElement('link');
        link.rel  = 'stylesheet';
        link.type = 'text/css';
        link.href = 'styles/' + applicationName + '.css';
        link.media = 'all';
        head.appendChild(link);
    };

    var getApplicationName = function(){
        return location.search.split('=')[1];
    };

    var applicationName = getApplicationName();
    loadCss('base');
    loadCss(applicationName);

})();