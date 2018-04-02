using Gtk;

namespace Parole {
	
	public class Parole : Gtk.Application {

		private ApplicationWindow window;

		// property
		public string master_password { get; set; default = "aaa"; }

		public string password_store_file = "/home/hannenz/Parole/passwords.xml";

		public Gdk.Pixbuf default_pixbuf;

		private Xml.Doc* xml_document;


		public Parole () {
			application_id = "de.hannenz.parole";
			flags |= GLib.ApplicationFlags.HANDLES_OPEN;
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

			default_pixbuf = new Gdk.Pixbuf.from_resource_at_scale ("/de/hannenz/parole/default_icon.png", 48, -1, true);
		}



		/**
		  * Open a password store file
		  *
		  * @param string 		The filename
		  * @return XmlNode* 	The XML Doc's root node
		  * @throws GLib.Error
		  */
		public Xml.Node* load_file (string filename) throws GLib.Error {

			var file_loader = new FileLoader ();
			var file = GLib.File.new_for_path (filename);
			/* try { */
				xml_document = file_loader.load (file, master_password);
			/* } */
			/* catch (GLib.Error e) { */
			/* 	stderr.printf ("Loading file %s failed: %s\n", filename, e.message); */
			/* } */

			Xml.Node *root_node = xml_document->get_root_element();
			if (root_node == null) {
				throw new GLib.Error (0, 0, "No root element in XML file found");
			}

			return root_node;
		}



		/**
		  * Get a category's node (in XML document)
		  *
		  * @param string 			The category's name
		  * @return Xml.Node*Node 	The XML node
		  */
		public Xml.Node* get_node_for_category (string category) {
			Xml.Node *node = null;
			Xml.XPath.Context ctx = new Xml.XPath.Context (xml_document);

			string expression = "//*[@category='" + category +"']";

			Xml.XPath.Object *res = ctx.eval_expression (expression);
			assert (res != null);
			assert (res->type == Xml.XPath.ObjectType.NODESET);
			assert (res->nodesetval != null);

			if (res->nodesetval->length () == 1) {
				node = res->nodesetval->item(0);
			}
			delete res;
			return node;
		}


		public void save_file () {
			xml_document->save_format_file_enc (password_store_file, "UTF-8", true);
		}

		public void preferences () {
			debug ("preferences: implemet me!");
		}
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
