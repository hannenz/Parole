#include <string.h>
#include <openssl/evp.h>
#include <gmp.h>

#define HASH_SIZE 64

static const char lowercase_chars[] = "abcdefghijklmnopqrstuvwxyz";
static const char uppercase_chars[] = "ABCDEFGHJKLMNPQRTUVWXYZ";
static const char digits[] = "0123456789";
static const char special_chars[] = "#!\"&$%&/()[]{}+-_+*<;:.";

/**
 * Generates a password for "domain", given the passed master_password and salt.
 * The password will have password_length characters containing only characters
 * from the string passed as allowed_characters
 *
 * The function returns allocated memory. For some reason (reference counting?)
 * do NOT free it!
 *
 * @param const char *domain
 * @param int password_length
 * @param const char *master_password
 * @param const char *salt
 * @param int iterations
 * @param char *allowed characters
 * 
 * @return const char *password 			The generated password for the domain
 */
char *generator_generate(
		const char *domain,
		int password_length,
		const char *master_password,
		const char *salt,
		int iterations,
		char *allowed_characters
	) {

	char *ac,
		*_ac,
		*password,
		*passphrase,
		*hash
	;

	int passphrase_len,
		remainder,
		i
	;

	mpz_t number,
		q,
		r
	;

	password = malloc(password_length + 1);
	passphrase_len = strlen(master_password) + strlen(domain) + 1;
	passphrase = malloc(passphrase_len);
	hash = malloc(HASH_SIZE);

	snprintf(passphrase, passphrase_len, "%s%s", domain, master_password);

	PKCS5_PBKDF2_HMAC(
		passphrase, strlen(passphrase),
		salt, strlen(salt),
		iterations,
		EVP_sha512(),
		HASH_SIZE,
		hash
	);

	if (allowed_characters == NULL) {
		int len = strlen(lowercase_chars) + strlen(uppercase_chars) + strlen(digits) + strlen(special_chars) + 1;
		_ac = malloc(len);
		_ac = strncpy(_ac, lowercase_chars, len);
		_ac = strncat(_ac, uppercase_chars, len);
		_ac = strncat(_ac, digits, len);
		_ac = strncat(_ac, special_chars, len);
		ac = _ac;
	}
	else {
		ac = allowed_characters;
	}


	mpz_inits(number, q, r, NULL);
	mpz_import(number, HASH_SIZE, 1, sizeof(char), 0, 0, hash);

	for (i = 0; i < password_length && (mpz_cmp_ui(number, 0)) > 0 ; i++) {
		remainder = (unsigned int)mpz_fdiv_qr_ui(q, r, number, strlen(ac));
		password[i] = ac[remainder];
		mpz_set(number, q);
	}
	password[i] = '\0';

	free(passphrase);
	free(hash);
	free(_ac);

	return password;
}

//~ void generator_free(void *p) {
	//~ free(p);
//~ }
