Accounts.prototype.decrypt = function (v3Keystore, password, nonStrict) {
          /* jshint maxcomplexity: 10 */

          if (!_.isString(password)) {
            throw new Error('No password given.');
          }

          var json = _.isObject(v3Keystore) ? v3Keystore : JSON.parse(nonStrict ? v3Keystore.toLowerCase() : v3Keystore);

          if (json.version !== 3) {
            throw new Error('Not a valid V3 wallet');
          }

          var derivedKey;
          var kdfparams;
          if (json.crypto.kdf === 'scrypt') {
            kdfparams = json.crypto.kdfparams;

            // FIXME: support progress reporting callback
            derivedKey = scryptsy(new Buffer(password), new Buffer(kdfparams.salt, 'hex'), kdfparams.n, kdfparams.r, kdfparams.p, kdfparams.dklen);
          } else if (json.crypto.kdf === 'pbkdf2') {
            kdfparams = json.crypto.kdfparams;

            if (kdfparams.prf !== 'hmac-sha256') {
              throw new Error('Unsupported parameters to PBKDF2');
            }

            derivedKey = cryp.pbkdf2Sync(new Buffer(password), new Buffer(kdfparams.salt, 'hex'), kdfparams.c, kdfparams.dklen, 'sha256');
          } else {
            throw new Error('Unsupported key derivation scheme');
          }

          var ciphertext = new Buffer(json.crypto.ciphertext, 'hex');

          var mac = utils.sha3(Buffer.concat([derivedKey.slice(16, 32), ciphertext])).replace('0x', '');
          if (mac !== json.crypto.mac) {
            throw new Error('Key derivation failed - possibly wrong password');
          }

          var decipher = cryp.createDecipheriv(json.crypto.cipher, derivedKey.slice(0, 16), new Buffer(json.crypto.cipherparams.iv, 'hex'));
          var seed = '0x' + Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString('hex');

          return this.privateKeyToAccount(seed);
        };