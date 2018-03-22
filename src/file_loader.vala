/**
 * FileLoader
 *
 * Class to load, (un)zip, and de/encrypt the XML storage file(s)
 *
 * Parole password files are AES encrypted ZIPed XML fils.
 */

using Xml;
using Archive;

namespace Parole {

	class FileLoader {

		protected unowned Xml.Doc XmlDoc;

//~ 		protected string filename;
//~ 
//~ 		protected string password;
		
		public FileLoader() {
		}

		/**
		 * Load a file, try to decrypt and unzip it
		 *
		 * @param GLib.File file 		The file
		 * @param string password 		The password used to decrypt
		 * 
		 * @return Xml.Node 			The root node of the XML document or NULL in case of an error
		 */
		public unowned Xml.Doc? load (File file, string password) {

			string file_contents, filename;
			size_t length;

			filename = file.get_path();
			debug("Opening file: %s\n", filename);
			try {
				FileUtils.get_contents(filename, out file_contents, out length);
			}
			catch (GLib.Error e) {
				error(e.message);
			}
			
			this.XmlDoc = Parser.parse_memory(file_contents, (int)length);
			if (this.XmlDoc == null) {
				stderr.printf("File not found or not readable\n");
				return null;
			}

			return this.XmlDoc;
		}

 		public bool save (string filename, string password) {

			// Read XmlDoc

			// Walk and write XML to string

			// ZIP it

			// encrypt it

			// Save to disk

 			return true;
 		}
	}
}
