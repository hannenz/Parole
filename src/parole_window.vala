using Granite;
using Xml;

namespace Parole {

	[GtkTemplate (ui="/de/hannenz/parole/window.ui")]
	public class ApplicationWindow : Gtk.ApplicationWindow {

		protected Xml.Doc *XmlDoc;

		[GtkChild]
		private Gtk.HeaderBar header;

		[GtkChild]
		private Gtk.Stack stack;

		[GtkChild]
		private Gtk.Box content_box;

		[GtkChild]
		private Gtk.Widget password_box;

		[GtkChild]
		private Gtk.Entry password_entry;

		[GtkChild]
		private Gtk.ScrolledWindow sidebar_sw;

		[GtkChild]
		private Gtk.Button lock_button;

		[GtkChild]
		private Gtk.Button new_button;

		[GtkChild]
		private Gtk.TreeView passwords_treeview;

		[GtkChild]
		private Gtk.TreeViewColumn password_column;

		[GtkChild]
		private Gtk.CellRendererText password_cell;

		private Gtk.ListStore passwords_liststore;

		public bool passwords_visible = false;

		private Granite.Widgets.AppMenu app_menu;

		private Granite.Widgets.SourceList sourcelist;

		/* [GtkCallback] */
		/* private void on_passwords_visible_button_clicked (Gtk.Button button) { */
		/* 	passwords_visible = !passwords_visible; */
		/* //	button.set_label(passwords_visible ? "Hide passwords" : "Show passwords"); */
		/* 	button.set_label(passwords_visible.to_string()); */
		/* } */

		[GtkCallback]
		public void on_password_entry_activated (Gtk.Entry entry) {
			/* stdout.printf ("You entered: %s\n", entry.get_text ()); */
			if ( entry.get_text () == "masterpassword" || true){
				stack.set_visible_child (content_box);	
				lock_button.show ();
				new_button.show ();
				app_menu.show_all ();
			}
			else {
				stdout.printf("Wrong password, try again...!\n");
			}
			password_entry.set_text("");
		}

		[GtkCallback]
		public void on_lock_button_clicked () {
			stack.set_visible_child(password_box);
			password_entry.grab_focus();
			new_button.hide ();
			lock_button.hide();
			app_menu.hide();
		}

		[GtkCallback]
		public void on_new_button_clicked () {
			message ("New button has been clicked");
		}

		public ApplicationWindow (Gtk.Application application) {
			GLib.Object (application: application);

			// passwords_visible = false;

			this.set_default_size(960,680);

			this.open(GLib.File.new_for_path("/home/hannenz/Parole/passwords.xml"));

			passwords_liststore = new Gtk.ListStore(
				6,
				typeof(string),				/* title */
				typeof(string),				/* url */
				typeof(string),				/* username */
				typeof(string),				/* password */
				typeof(string),				/* remark */
				typeof(Xml.Node) 				/* XML node */
			);
			passwords_treeview.set_model(passwords_liststore);
			passwords_treeview.row_activated.connect(on_passwords_treeview_row_activated);

			var selection = passwords_treeview.get_selection();
			selection.set_mode(Gtk.SelectionMode.SINGLE);
			selection.changed.connect(on_passwords_treeview_selection_changed);

			password_column.set_cell_data_func(password_cell, (Gtk.CellLayoutDataFunc)render_password);

			/* var menu = new Gtk.Menu(); */
			/* var item = new Gtk.MenuItem.with_label("New entry"); */
			/* item.activate.connect(on_new_entry); */
			/* menu.add(item); */
            /*  */
			/* item = new Gtk.MenuItem.with_label ("Foo bar"); */
			/* menu.add (item); */
            /*  */
			/* app_menu = new Granite.Widgets.AppMenu(menu); */
			/* header.pack_end(app_menu); */
			/* app_menu.show_all(); */
		}

		private void on_new_entry() {
			Granite.Widgets.SourceList.Item sl_item = sourcelist.selected;
			if (sl_item != null) {
				debug ("New item for category: " + sl_item.name);
			}

			var dlg = new PasswordEntryDialog(new PasswordEntry(), "");
			dlg.show_all();
			var response = dlg.run();
			if (response == Gtk.ResponseType.APPLY) {
				Xml.Node *category = get_node_for_category(sl_item.name);
				Xml.Node *entry = create_password_entry_xml(
					dlg.pwEntry.title,
					dlg.pwEntry.url,
					dlg.pwEntry.username,
					dlg.pwEntry.secret,
					dlg.pwEntry.remark
				);
				category->add_child(entry);

				Gtk.TreeIter iter;
				passwords_liststore.append(out iter);
				passwords_liststore.set(
					iter,
					0, dlg.pwEntry.title,
					1, dlg.pwEntry.url,
					2, dlg.pwEntry.username,
					3, dlg.pwEntry.secret,
					4, dlg.pwEntry.remark
				);
			}
			dlg.destroy();
		}

		private Xml.Node* get_node_for_category(string category) {
			Xml.Node *node = null;
			Xml.XPath.Context ctx = new Xml.XPath.Context(XmlDoc);

			string expression = "//*[@category='" + category +"']";

			Xml.XPath.Object *res = ctx.eval_expression(expression);
			assert (res != null);
			assert (res->type == Xml.XPath.ObjectType.NODESET);
			assert (res->nodesetval != null);

			if (res->nodesetval->length() == 1) {
				node = res->nodesetval->item(0);
			}
			delete res;
			return node;
		}

		private Xml.Node* create_password_entry_xml(string title, string url, string username, string secret, string remark) {
			Xml.Ns ns = new Xml.Ns(null, "", "Parole");
			Xml.Node *entry = new Xml.Node(ns, "entry");
			entry->new_prop("title", title);
			entry->new_text_child(ns, "url", url);
			entry->new_text_child(ns, "username", username);
			entry->new_text_child(ns, "secret", secret);
			entry->new_text_child(ns, "remark", remark);
			return entry;
		}

		public void render_password (/*Gtk.CellLayout layout, */Gtk.CellRendererText cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
//			debug (passwords_visible.to_string());
			/* if (passwords_visible == false && false) { */
				cell.set_property("text", "∙∙∙∙∙∙");
			/* } */
		}

		public void open (GLib.File file){
			var filename = file.get_path();
			debug("Opening file: %s\n", filename);
			XmlDoc = Parser.parse_file(filename);
			if (XmlDoc == null) {
				stderr.printf("File not found or not readable\n");
				return;
			}

			Xml.Node *rootNode = XmlDoc->get_root_element();
			if (rootNode == null) {
				stderr.printf("No root element in XML file found\n");
				return;
			}

			sourcelist = new Granite.Widgets.SourceList();
			var root = sourcelist.root;
			var categories_item = new Granite.Widgets.SourceList.ExpandableItem("Categories");

			if (rootNode->name == "database") {
				add_passwords(rootNode, categories_item);
			}

			root.add(categories_item);
			root.expand_all(true, false);
			sourcelist.item_selected.connect(on_source_list_item_selected);

			sidebar_sw.add(sourcelist);

			sourcelist.show();
		}

		private void add_passwords(Xml.Node *node, Granite.Widgets.SourceList.ExpandableItem sourceListItem) {

			// assert (node->name == "passwords");

			for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {

				if (iter->type == Xml.ElementType.ELEMENT_NODE && iter->name == "passwords") {

					var category = iter->get_prop("category");
					var n_children = iter->child_element_count();

					if (category != null) {

						if (n_children > 0) {

							var item = new Granite.Widgets.SourceList.ExpandableItem(category);
							sourceListItem.add(item);
							add_passwords(iter, item);
						}
						else {
							var item = new Granite.Widgets.SourceList.Item(category);
							sourceListItem.add(item);
						}

					}
				}
			}
		}

		private void on_source_list_item_selected(Granite.Widgets.SourceList.Item? item) {

			Xml.Node *node = get_node_for_category(item.name);


			passwords_liststore.clear();

			for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {

				if (iter->type == Xml.ElementType.ELEMENT_NODE && iter->name == "entry") {

					var passwordEntry = new PasswordEntry();
					passwordEntry.title = iter->get_prop("title");
					passwordEntry.url = findSubNode(iter, "url");
					passwordEntry.username = findSubNode(iter, "username");
					passwordEntry.secret = findSubNode(iter, "secret");
					passwordEntry.remark = findSubNode(iter, "remark");

					Gtk.TreeIter tree_iter;

					passwords_liststore.append(out tree_iter);
					passwords_liststore.set(tree_iter,
						0, passwordEntry.title,
						1, passwordEntry.url,
						2, passwordEntry.username,
						3, passwordEntry.secret,
						4, passwordEntry.remark,
						5, iter
					);
				}
			}
		}

		private string? findSubNode(Xml.Node *node, string name) {

			assert (node->name == "entry");

			for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
				if (iter->type == Xml.ElementType.ELEMENT_NODE && iter->name == name) {
					return iter->get_content();
				}
			}
			return null;
		}

		private void on_passwords_treeview_selection_changed(Gtk.TreeSelection selection) {
			Gtk.TreeIter iter;
			Gtk.TreeModel model;
			string title;

			if (selection.get_selected(out model, out iter)) {
				model.get(iter, 0, out title);
				debug (title + " has been selected");
			}
		}

		private void on_passwords_treeview_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column) {
			Gtk.TreeIter iter;
			var passwordEntry = new PasswordEntry();

			passwords_liststore.get_iter(out iter, path);

			passwords_liststore.get(iter,
				0, out passwordEntry.title,
				1, out passwordEntry.url,
				2, out passwordEntry.username,
				3, out passwordEntry.secret,
				4, out passwordEntry.remark
			);


			var dlg = new PasswordEntryDialog(passwordEntry, "");
			dlg.show_all();
			var response = dlg.run();
			if (response == Gtk.ResponseType.APPLY) {
				passwords_liststore.set(iter,
					0, dlg.pwEntry.title,
					1, dlg.pwEntry.url,
					2, dlg.pwEntry.username,
					3, dlg.pwEntry.secret,
					4, dlg.pwEntry.remark
				);

				// Save password entry in XML doc
				Xml.Node *node;
				passwords_liststore.get(iter, 5, out node);

				node->set_prop ("last-change", new GLib.DateTime.now_local ().to_string ());
				node->set_prop ("title", dlg.pwEntry.title);
				for (Xml.Node *subnode = node->children; subnode != null; subnode = subnode->next) {
					if (subnode->type == Xml.ElementType.ELEMENT_NODE) {
						switch (subnode->name) {
							case "url":
								subnode->set_content (dlg.pwEntry.url);
								break;
							case "username":
								subnode->set_content (dlg.pwEntry.username);
								break;
							case "secret":
								subnode->set_content (dlg.pwEntry.secret);
								break;
							case "remark":
								subnode->set_content (dlg.pwEntry.remark);
								break;
						}
					}
				}
				message ("Saving xml document\n");
				XmlDoc->save_file ("/home/hannenz/Parole/passwords.xml");
			}
			dlg.destroy();
		}
	}
}
