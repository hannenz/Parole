using Gtk;

namespace Parole {
	
	public class Parole : Gtk.Application {

		private ApplicationWindow window;

		// property
		public string master_password { get; set; default = "abc"; }

		// The Model 
		public TreeStore password_store;

		private string password_store_file = "/home/hannenz/Parole/passwords.xml";

		private Xml.Doc* xml_document;



		public Parole () {
			application_id = "de.hannenz.parole";
			flags |= GLib.ApplicationFlags.HANDLES_OPEN;

			info (master_password);

		}



		public override void activate () {

			// Load Style Sheet (Custom CSS)
			var screen = Gdk.Display.get_default ().get_default_screen ();
			var provider = new Gtk.CssProvider ();
			provider.load_from_resource ("de/hannenz/parole/parole.css");
			Gtk.StyleContext.add_provider_for_screen (screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

			window = new ApplicationWindow (this);
			window.present();

			var entry = Unity.LauncherEntry.get_for_desktop_id ("de.hannenz.parole.desktop");
			entry.count_visible = true;
			entry.count = 12;

			// Create a root quicklist
			var quicklist = new Dbusmenu.Menuitem ();

			// Create root's children
			var item1 = new Dbusmenu.Menuitem ();
			item1.property_set (Dbusmenu.MENUITEM_PROP_LABEL, "Item 1");
			item1.item_activated.connect (() => {
				message ("Item 1 activated");
			});

			var item2 = new Dbusmenu.Menuitem ();
			item2.property_set (Dbusmenu.MENUITEM_PROP_LABEL, "Item 2");
			item2.item_activated.connect (() => {
				message ("Item 2 activated");
			});

			// Add children to the quicklist
			quicklist.child_append (item1);
			quicklist.child_append (item2);

			// Finally, tell libunity to show the desired quicklist
			entry.quicklist = quicklist;

			password_store = new Gtk.TreeStore (7, 
					typeof (string), 		// title
					typeof (string), 		// url
					typeof (string), 		// usernmae
					typeof (string), 		// password / secret
					typeof (string), 		// remark
					typeof (Gdk.Pixbuf), 	// Image
					typeof (Xml.Node) 		// node in XML doc
			);

			load_xml (password_store_file);

			var window = new Gtk.Window ();
			var tv = new Gtk.TreeView.with_model (password_store);
			window.add (tv);
			var cell = new Gtk.CellRendererText ();
			tv.insert_column_with_attributes (-1, "Title", cell, "text", 0);
			tv.insert_column_with_attributes (-1, "URL", cell, "text", 1);
			tv.insert_column_with_attributes (-1, "Username", cell, "text", 2);

			window.show_all ();
			window.present ();

		}



		protected void load_xml (string filename) {

			xml_document = Xml.Parser.parse_file (filename);
			if (xml_document == null) {
				stderr.printf ("File not found or not readable\n");
				return;
			}

			Xml.Node *root_node = xml_document->get_root_element ();
			if (root_node == null) {
				delete xml_document;
				stderr.printf("No root element in XML file found\n");
				return;
			}

			/* Gtk.TreeIter iter; */
			parse_node (root_node, null);
		}



		private void parse_node (Xml.Node* parent_node, Gtk.TreeIter? parent_iter) {

			Gtk.TreeIter iter;

			for (Xml.Node* node = parent_node->children; node != null; node = node->next) {
				if (node->type != Xml.ElementType.ELEMENT_NODE) {
					continue;
				}
				if (node->name == "entry") {
					// Element: Insert into password_store to last position (append)
					password_store.insert (out iter, parent_iter, -1);

					info ("url: %s", node_get_subnode (node, "url"));

					password_store.set (iter, 
						0, node_get_attribute (node, "title"),
						1, node_get_subnode   (node, "url"),
						2, node_get_subnode   (node, "username"),
						3, node_get_subnode   (node, "secret"),
						4, node_get_subnode   (node, "remark"),
						5, null, // TODO: Implement me!
						6, node
					);
				}
				else if (node->name == "passwords") {
					password_store.insert (out iter, parent_iter, -1);
					password_store.set (iter, 
						0, node_get_attribute (node, "category"),
						6, node
					);
					parse_node (node, iter);
				}
			}
		}



		/**
		  * Get an attribute from a XML node
		  *
		  * @param Xml.Node 		The XML node
		  * @param string 			The attribute's name
		  * @return string 			The attribute's value
		  */
		private string node_get_attribute (Xml.Node *node, string attr_name) {
			for (Xml.Attr *attr = node->properties; attr != null; attr = attr->next) {
				if (attr->name == attr_name) {
					return attr->children->content;
				}
			}
			return "";
		}



		/**
		  * Get a subnode
		  *
		  * @param Xml.Node 		The XML node
		  * @param string 			The subnode's name
		  * @return string 			The subnode's content
		  */
		private string node_get_subnode (Xml.Node *node, string subnode_name) {
			for  (Xml.Node *child = node->children; child != null; child = child->next) {
				if (child->type != Xml.ElementType.ELEMENT_NODE) {
					continue;
				}
				debug (child->name);
				if (child->name == subnode_name) {
					debug ("*** MATCH !!! ***: " + child->get_content ());
					return child->get_content ();
				}
			}
			return "";
		}







		protected override void startup () {
			base.startup ();
			var action = new GLib.SimpleAction ("preferences", null);
			action.activate.connect (preferences);
			add_action (action);

			action = new GLib.SimpleAction ("quit", null);
			action.activate.connect (quit);
			add_action (action);

			add_accelerator ("<Ctrl>Q", "app.quit", null);

			action = new GLib.SimpleAction ("add-entry", null);
			add_action (action);

			action = new GLib.SimpleAction ("edit-entry", null);
			add_action (action);

			action = new GLib.SimpleAction ("delete-entry", null);
			add_action (action);

			var builder = new Gtk.Builder.from_resource ("/de/hannenz/parole/ui/app_menu.ui");
			var app_menu = builder.get_object ("app_menu") as GLib.MenuModel;

			set_app_menu (app_menu);
		}



		public void preferences () {
			debug ("preferences: implemet me!");
		}



		/* public override void open (GLib.File[] files, string hint){ */
		/* 	if (window == null){ */
		/* 		window = new ApplicationWindow	 (this); */
		/* 	} */
		/* 	foreach (var file in files) { */
		/* 		window.open (file); */
		/* 	} */
		/* 	window.present(); */
		/* } */
	}



    public static int main (string[] args) {

		/* var favicon_scraper = new FaviconScraper (); */
		/* favicon_scraper.scraped.connect ( (favicon) => { */
		/* 	// do something... */
		/* 	debug ("Scraped...!"); */
		/* }); */
		/* favicon_scraper.scrape ("twitter.com"); */
		/* return 0; */
        /*  */
        var application = new Parole ();
        return application.run (args);
    }
}
