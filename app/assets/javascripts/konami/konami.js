$(window).konami({  
    cheat: function() {
    	pics = ["http://i.imgur.com/Z0gEBTs.png",
	    	"http://th03.deviantart.net/fs70/PRE/i/2012/072/1/0/_004_glumanda___charmander_by_mrsjasminhardy-d4smf2i.png",
	    	"http://images4.wikia.nocookie.net/__cb20110525005411/pokemon/images/3/39/007Squirtle.png",
	    	"http://1.bp.blogspot.com/-dFY0ZWIx9L4/UaQMVOOUvjI/AAAAAAAAE_o/oc6hO_C4poQ/s1600/Bulbasaur+%25281%2529.png"
	    ];
    	pikafy(pics);
    	var n = $(".image-container img").length
    	setInterval(function() { n = checkChange(n, pics); }, 100);
    }
});

function pikafy(pics) {
	$(".image-container img").each(function() {
		if(!$(this).attr("data-konami")) {
			$(this).attr("src", pics[Math.floor(Math.random() * pics.length)]);
			$(this).attr("data-konami", "yes");
		}
	});
}

function checkChange(n, pics)
{
    if($(".image-container img").length > n)
    	pikafy(pics);
    return $(".image-container img").length
}