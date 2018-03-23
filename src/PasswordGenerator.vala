namespace Parole {

	/**
	  * TODO: 
	  * - Check if pwgen is available
	  * - On show, focus the entry
	  */

	[GtkTemplate (ui="/de/hannenz/parole/password_generator.ui")]
	public class PasswordGenerator : Gtk.Popover {

		[GtkChild]
		private Gtk.Entry generated_password_entry;

		[GtkChild]
		private Gtk.SpinButton generator_spin_button;

		public PasswordGenerator () {
			debug ("Creating Generator Popover");
			generated_password_entry.activate.connect ( apply );
		}


		[GtkCallback]
		private void on_generator_spin_button_value_changed () {
			regenerate_password ();
		}


		/**
		  * Generate a password with pwgen and poplate
		  * the password entry with it
		  */
		public void regenerate_password () {
			int exit_status;
			string standard_output, standard_error;
			Process.spawn_command_line_sync ("pwgen %u 1".printf (generator_spin_button.get_value_as_int ()), out standard_output,
                                               out standard_error,
                                               out exit_status);

			generated_password_entry.set_text (standard_output.chomp ());
		}

		public void apply () {
			debug ("Applying");
			var secret_entry = this.get_relative_to () as Gtk.Entry;
			secret_entry.set_text (generated_password_entry.get_text ());
			hide ();
		}
	}
}
