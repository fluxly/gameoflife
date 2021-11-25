var UnrulyAppsList = [
	"foo", "bar", "baz", "gum", "bax", "bex"
]

var UnrulyApps = {
	"foo" : {
		 name : "Foo", 
		 splapp : "foo.splapp", 
		 type : "static-web",
		 loaded : false,
		 icon : "images/apps/icons/foo.svg",
		 setup : function() { console.log("hoo boy"); },
	},
	"bar" : {
	     name : "Bar", 
		splapp : "bar.splapp", 
		 type : "dynamic-web",
		 loaded : false,
		 icon : "images/apps/icons/bar.svg",
	     setup : function() { console.log("wow"); },
	},
	"baz" : {
	     name : "Baz", 
		splapp : "baz.splapp", 
		 type : "p5",
		 loaded : false,
		 icon : "images/apps/icons/baz.svg",
	     setup : function() { console.log("hooey"); },
	},
	"gum" : {
	     name : "Gum", 
		splapp : "gum.splapp", 
		 type : "p5",
		 loaded : false,
		 icon : "images/apps/icons/gum.svg",
	     setup : function() { console.log("gum"); },
	},
	"bax" : {
	     name : "Bax", 
		splapp : "bax.splapp", 
		 type : "p5",
		 loaded : false,
		 icon : "images/apps/icons/baz.svg",
	     setup : function() { console.log("hooey"); },
	},
	"bex" : {
	     name : "Bex", 
		splapp : "bex.splapp", 
		 type : "p5",
		 loaded : false,
		 icon : "images/apps/icons/baz.svg",
	     setup : function() { console.log("gum"); },
	}
}