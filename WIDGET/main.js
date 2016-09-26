'use strict';
(function () {

    var newMsg = 0;

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

	
	// Initialize Firebase
	var config = {
		apiKey: "AIzaSyBWVyFwFb0WCQ8umii9tyHNlPvVm15OJnA",
		authDomain: "af-notif-widget-484c6.firebaseapp.com",
		databaseURL: "https://af-notif-widget-484c6.firebaseio.com",
		storageBucket: "af-notif-widget-484c6.appspot.com",
		messagingSenderId: "638447157736"
	  };
	firebase.initializeApp(config);

	
	
	firebase.database().ref('messages/').on('child_added', function(snap) {
        var time=$('<div/>',{class:'col-xs-12 time', html: '<span>Il y a 8mn - Alerte Nettoyage par A.Dumère (EMB-R)</span>'});
        var text=$('<div/>',{class:'col-xs-12 text', html: '&laquo;'+snap.val().text+'&raquo;'});
        var msg=$('<div/>',{class:'row message'});
        msg.append(time);
        msg.append(text);
        $(".messages").append(msg);
        if (!$('.detail').is(":visible")) {
            newMsg++;
            $('.btn-alert').text(newMsg);
        }
	});

	$('.btn-submit').on('click', function() {
		if ($('#message').val()) {
			var newPostKey = firebase.database().ref('messages/').push().key;
			
			var updates = {};
			updates[newPostKey] = {text:$('#message').val()};
			firebase.database().ref('messages/').update(updates);
		}
	});
	
	$('.btn-alert').on('click', function() {
		$('.detail').show();
		$('.container').addClass('opened');

        newMsg = 0;
        $('.btn-alert').text(newMsg);
	});
	
	$('.btn-close').on('click', function() {
		$('.container').removeClass('opened');
		$('.detail').hide();
	});
})();