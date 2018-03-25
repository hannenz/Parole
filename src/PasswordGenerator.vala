namespace Parole {

	/**
	  * TODO: 
	  * - Check if pwgen is available
	  * - On show, focus the entry
	  */

	[GtkTemplate (ui="/de/hannenz/parole/ui/password_generator.ui")]
	public class PasswordGenerator : Gtk.Popover {

		[GtkChild]
		private Gtk.Entry generated_password_entry;

		[GtkChild]
		private Gtk.SpinButton generator_spin_button;

		[GtkChild]
		private Gtk.CheckButton use_symbols_cb;

		/* [GtkChild] */
		/* private Gtk.CheckButton secure_cb; */



		protected bool use_symbols = false;

		protected bool secure = false;


		[GtkCallback]
		private void apply () {
			var secret_entry = this.get_relative_to () as Gtk.Entry;
			secret_entry.set_text (generated_password_entry.get_text ());
			hide ();
		}

		[GtkCallback]
		public void cancel () {
			hide ();
		}

		[GtkCallback]
		private void on_change_regenerate_password () {
			use_symbols = use_symbols_cb.get_active ();
			/* secure = secure_cb.get_active (); */
			regenerate_password ();
		}



		/**
		  * Generate a password with pwgen and poplate
		  * the password entry with it
		  */
		public void regenerate_password () {
			int exit_status;
			string standard_output, standard_error;

			string pwgen_options = "--ambiguous --capitalize --numerals --no-vowels";
			if (use_symbols) {
				pwgen_options += " --symbols";
			}

			string cmd = "pwgen %s %u 1".printf (pwgen_options, generator_spin_button.get_value_as_int ());
			try {
				Process.spawn_command_line_sync (cmd, out standard_output, out standard_error, out exit_status);
				generated_password_entry.set_text (standard_output.chomp ());
			}
			catch (Error e) {
				stderr.printf ("Error: %s\n", e.message);
			}
		}
	}
}
