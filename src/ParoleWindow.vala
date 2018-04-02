using Granite;
using Xml;

namespace Parole {

	[GtkTemplate (ui="/de/hannenz/parole/ui/window.ui")]
	public class ApplicationWindow : Gtk.ApplicationWindow {

		protected Parole app;

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
		private Gtk.Label title_label;

		[GtkChild]
		private Gtk.Button new_button;

		[GtkChild]
		private Gtk.Button back_button;

		[GtkChild]
		private Gtk.Button app_menu_button;

		[GtkChild]
		private Gtk.TreeView passwords_treeview;

		/* [GtkChild] */
		/* private Gtk.ListBox passwords_listbox; */

		[GtkChild]
		private Gtk.TreeViewColumn password_column;

		[GtkChild]
		private Gtk.CellRendererText password_cell;

		private Gtk.ListStore passwords_liststore;

		public bool passwords_visible = false;

		private Granite.Widgets.AppMenu app_menu;

		private Granite.Widgets.SourceList sourcelist;

		[GtkChild]
		private Gtk.Label master_password_message;

		protected PasswordEditView password_edit_view;



		/**
		  * Constructor
		  */
		public ApplicationWindow (Parole application) {
			GLib.Object (application: application);
			app = application;

			this.set_default_size (960,680);
			this.open (app.password_store_file);

			passwords_liststore = new Gtk.ListStore (
				7,
				typeof(string),				/* title */
				typeof(string),				/* url */
				typeof(string),				/* username */
				typeof(string),				/* password */
				typeof(string),				/* remark */
				typeof(Xml.Node), 				/* XML node */
				typeof(Gdk.Pixbuf)
			);
			passwords_treeview.set_model(passwords_liststore);
			passwords_treeview.row_activated.connect(on_passwords_treeview_row_activated);

			var selection = passwords_treeview.get_selection();
			selection.set_mode(Gtk.SelectionMode.SINGLE);
			selection.changed.connect(on_passwords_treeview_selection_changed);

			password_column.set_cell_data_func(password_cell, (Gtk.CellLayoutDataFunc)render_password);

			password_edit_view = new PasswordEditView (new PasswordEntry (), "");

			stack.add_named (password_edit_view, "edit");

#if WITH_GRANITE
			back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
#endif
		}


		[GtkCallback]
		public void on_password_entry_activated (Gtk.Entry entry) {
			/* stdout.printf ("You entered: %s\n", entry.get_text ()); */
			if ( entry.get_text () == app.master_password){
				stack.set_visible_child (content_box);	
				lock_button.show ();
				new_button.show ();
				app_menu.show_all ();
				title_label.hide ();
			}
			else {
				master_password_message.set_markup ("<span color=\"#c00000\" font_weight=\"normal\">Wrong password, please try again…</span>");
				master_password_message.show ();
			}
			password_entry.set_text("");
		}

		[GtkCallback]
		public void on_lock_button_clicked () {
			stack.set_visible_child (password_box);
			password_entry.grab_focus ();
			new_button.hide ();
			lock_button.hide ();
			app_menu.hide ();
			title_label.show ();
		}


		[GtkCallback]
		public void on_menu_button_clicked () {
			var app_menu = application.get_app_menu () as Gtk.Menu;
		//	app_menu.popup_at_widget (app_menu_button, Gdk.Gravity.SOUTH, Gdk.Gravity.SOUTH, null);
			app_menu.popup (null, null, null, 0, 0);
		}



		[GtkCallback]
		private void on_new_entry() {
			Granite.Widgets.SourceList.Item sl_item = sourcelist.selected;
			if (sl_item != null) {
				debug ("New item for category: " + sl_item.name);
			}

			var password_entry = new PasswordEntry ();
			password_edit_view.set_password_entry (password_entry);
			stack.set_visible_child (password_edit_view);
			back_button.show ();
			return;



			var dlg = new Gtk.Dialog.with_buttons ("Add a new password entry", this, 0, "_Cancel", Gtk.ResponseType.CANCEL, "_OK", Gtk.ResponseType.ACCEPT);
			var content_area = dlg.get_content_area ();
			var view = new PasswordEditView (password_entry, "");
			content_area.add (view);

			if (dlg.run () == Gtk.ResponseType.ACCEPT) {
				password_entry = view.get_password_entry ();

				Xml.Node *category = app.get_node_for_category(sl_item.name);

				Xml.Node *entry = new Xml.Node (null, "entry");
				entry->new_prop ("title", password_entry.title);
				entry->new_text_child (null, "url", password_entry.url);
				entry->new_text_child (null, "username", password_entry.username);
				entry->new_text_child (null, "secret", password_entry.secret);
				entry->new_text_child (null, "remark", password_entry.remark);
				category->add_child (entry);
				app.save_file ();

				Gtk.TreeIter iter;
				passwords_liststore.append (out iter);
				passwords_liststore.set(
					iter,
					0, password_entry.title,
					1, password_entry.url,
					2, password_entry.username,
					3, password_entry.secret,
					4, password_entry.remark
				);
			}

			dlg.close ();
			dlg.destroy ();
		}


		public void render_password (/*Gtk.CellLayout layout, */Gtk.CellRendererText cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
			cell.set_property("text", "∙∙∙∙∙∙");
		}


		public void open (string filename) {
			Xml.Node *root_node = null;
			try {
				root_node = this.app.load_file (filename);
			}
			catch (GLib.Error e) {
				// TODO: Create a dialog or infobar messageor something similar...
				stderr.printf ("Loading failed: %s\n", e.message);
			}

			sourcelist = new Granite.Widgets.SourceList ();
			var root = sourcelist.root;
			var categories_item = new Granite.Widgets.SourceList.ExpandableItem ("Categories");

			add_passwords (root_node, categories_item);

			root.add (categories_item);
			root.expand_all (true, false);
			sourcelist.item_selected.connect (on_source_list_item_selected);

			sidebar_sw.add (sourcelist);

			sourcelist.show ();
		}



		private void add_passwords(Xml.Node *node, Granite.Widgets.SourceList.ExpandableItem sourceListItem) {

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

			Xml.Node *node = app.get_node_for_category(item.name);

			passwords_liststore.clear();

			for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {

				if (iter->type == Xml.ElementType.ELEMENT_NODE && iter->name == "entry") {

					var passwordEntry = new PasswordEntry();
					passwordEntry.title = iter->get_prop("title");
					passwordEntry.url = findSubNode(iter, "url");
					passwordEntry.username = findSubNode(iter, "username");
					passwordEntry.secret = findSubNode(iter, "secret");
					passwordEntry.remark = findSubNode(iter, "remark");

					var image_str = findSubNode (iter, "image");

					try {
						var loader = new Gdk.PixbufLoader ();
						loader.write (Base64.decode (image_str));
						loader.close ();
						passwordEntry.pixbuf = loader.get_pixbuf ();
					}
					catch (GLib.Error e) {
						stderr.printf ("Error: %s\n", e.message);
						passwordEntry.pixbuf = app.default_pixbuf;
					}


					Gtk.TreeIter tree_iter;

					passwords_liststore.append(out tree_iter);
					passwords_liststore.set(tree_iter,
						0, passwordEntry.title,
						1, passwordEntry.url,
						2, passwordEntry.username,
						3, passwordEntry.secret,
						4, passwordEntry.remark,
						5, iter,
						6, passwordEntry.pixbuf
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
			}
		}



		private void on_passwords_treeview_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column) {
			Gtk.TreeIter iter;
			var password_entry = new PasswordEntry();

			passwords_liststore.get_iter(out iter, path);
			passwords_liststore.get(iter,
				0, out password_entry.title,
				1, out password_entry.url,
				2, out password_entry.username,
				3, out password_entry.secret,
				4, out password_entry.remark,
				6, out password_entry.pixbuf
			);

			/* password_edit_view.set_password_entry (password_entry); */
			/* stack.set_visible_child (password_edit_view); */
			/* back_button.show (); */
            /*  */
			/* return; */
            /*  */
			var dlg = new Gtk.Dialog.with_buttons ("Edit password entry", this, 0, "_Cancel", Gtk.ResponseType.CANCEL, "_OK", Gtk.ResponseType.ACCEPT);
			dlg.set_default_response  (Gtk.ResponseType.ACCEPT);
			var view = new PasswordEditView (password_entry, "");
			var content_area = dlg.get_content_area ();
			content_area.add (view);
			view.pwned.connect ( () => {
				var info_bar = new Gtk.InfoBar ();
				info_bar.message_type = Gtk.MessageType.ERROR;
				info_bar.show_close_button = true;
				var label = new Gtk.Label (null);
				label.set_markup ("This password has been pawned and should not be used anymore.\nPassword check by <a href=\"https://haveibeenpwned.com\" title=\"https://haveibeenpwned.com\">https://haveibeenpawned.com</a>");
				info_bar.get_content_area ().add (label);
				info_bar.response.connect ( () => {
					info_bar.destroy ();
				});

				content_area.pack_start (info_bar);
				info_bar.show_all ();
			});

			if (dlg.run () == Gtk.ResponseType.ACCEPT) {
				password_entry = view.get_password_entry ();
				password_entry.dump ();
				passwords_liststore.set(iter,
					0, password_entry.title,
					1, password_entry.url,
					2, password_entry.username,
					3, password_entry.secret,
					4, password_entry.remark
				);

				// Save password entry in XML doc
				Xml.Node *node;
				passwords_liststore.get(iter, 5, out node);

				node->set_prop ("last-change", new GLib.DateTime.now_local ().to_string ());
				node->set_prop ("title", password_entry.title);
				for (Xml.Node *subnode = node->children; subnode != null; subnode = subnode->next) {
					if (subnode->type == Xml.ElementType.ELEMENT_NODE) {
						switch (subnode->name) {
							case "url":
								subnode->set_content (password_entry.url);
								break;
							case "username":
								subnode->set_content (password_entry.username);
								break;
							case "secret":
								subnode->set_content (password_entry.secret);
								break;
							case "remark":
								subnode->set_content (password_entry.remark);
								break;
							case "image":
								try {

									uint8[] buf;
									password_entry.pixbuf.save_to_buffer (out buf, "jpeg");
									debug (Base64.encode (buf));
									subnode->set_content (Base64.encode (buf));
									/* password_entry.pixbuf.save_to_callback ( (buf) => { */
									/* 	subnode->set_content (Base64.encode (buf)); */
									/* 	return true; */
									/* }, "png"); */
								}
								catch (GLib.Error e) {
									stderr.printf ("Error: %s\n", e.message);
								}
								break;

								debug (password_entry.pixbuf.get_width ().to_string ());
								debug (password_entry.pixbuf.get_height ().to_string ());
								var h = password_entry.pixbuf.get_height ();
								var r = password_entry.pixbuf.get_rowstride ();
								var w = password_entry.pixbuf.get_width ();
								var b = password_entry.pixbuf.get_bits_per_sample ();
								var n = password_entry.pixbuf.get_n_channels ();

								var size = r * (h - 1);
								size += w  * ((n * b) + 7 / 8);
								debug (size.to_string ());

								subnode->set_prop ("width", password_entry.pixbuf.get_width ().to_string ());
								subnode->set_prop ("height", password_entry.pixbuf.get_height ().to_string ());
								subnode->set_prop ("rowstride", password_entry.pixbuf.get_rowstride ().to_string ());
								subnode->set_prop ("has_alpha", password_entry.pixbuf.get_has_alpha () ? "1" : "0");
								var data = password_entry.pixbuf.get_pixels ();
								/* var len = dlg.pwEntry.pixbuf.get_byte_length (); */
								/* debug (len.to_string ()); */
								/* data[len] = '\0'; */

								/* subnode->set_content (Base64.encode (data)); */
								break;
						}
					}
				}
				message ("Saving xml document\n");
				app.save_file ();
			}

			dlg.close ();
			dlg.destroy ();
		}

		[GtkCallback]
		private void on_back_button_clicked () {
			stack.set_visible_child (content_box);
			back_button.hide ();
		}
	}
}
