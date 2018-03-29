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

		protected unowned Xml.Doc* xml_document;

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
		public unowned Xml.Doc* load (File file, string password) throws GLib.Error {

			string file_contents, filename;
			size_t length;
			Xml.Node* root_node;

			filename = file.get_path();
			debug("Opening file: %s\n", filename);

			/**
			  * We read to memory bacause later we will have to decode the file
			  * first, so we cannot use Xml.Parser.parse_file () here
			  */
			FileUtils.get_contents(filename, out file_contents, out length);

			/**
			  * TODO: Implement AES decryption here
			  */

			if ((xml_document = Parser.parse_memory(file_contents, (int)length)) == null) {
				throw new GLib.Error (0, 0, "Failed to parse XML from file");
			}
			if ((root_node = xml_document->get_root_element()) == null) {
				throw new GLib.Error (0, 0, "No root node found in XML document");
			}
			if (root_node->name != "passwordstore") {
				throw new GLib.Error (0, 0, "Invalid root node name");
			}

			return xml_document;
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
