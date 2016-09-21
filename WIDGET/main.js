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

	
	// Initialize Firebase
	var config = {
		apiKey: "AIzaSyBWVyFwFb0WCQ8umii9tyHNlPvVm15OJnA",
		authDomain: "af-notif-widget-484c6.firebaseapp.com",
		databaseURL: "https://af-notif-widget-484c6.firebaseio.com",
		storageBucket: "af-notif-widget-484c6.appspot.com",
		messagingSenderId: "638447157736"
	  };
	firebase.initializeApp(config);

	
	
	firebase.database().ref('messages/').on('value', function(snapshot) {
		snapshot.forEach(function(snap) {
			$("#messages").append('<p>'+snap.val().text+'</p>');
			console.log(snap.val().text);
		});
	});
	
	$('#addBtn').on('click', function() {
		if ($('#message').val()) {		
			var newPostKey = firebase.database().ref('messages/').push().key;
			
			var updates = {};
			updates[newPostKey] = {text:$('#message').val()};
			firebase.database().ref('messages/').update(updates);
		}
	});
})();