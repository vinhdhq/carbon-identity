CREATE TABLE IDN_BASE_TABLE (
            PRODUCT_NAME LVARCHAR(20),
            PRIMARY KEY (PRODUCT_NAME)
);

INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');

CREATE TABLE IDN_OAUTH_CONSUMER_APPS (
            CONSUMER_KEY LVARCHAR(255),
            CONSUMER_SECRET LVARCHAR(512),
            USERNAME LVARCHAR(255),
            TENANT_ID INTEGER DEFAULT 0,
            APP_NAME LVARCHAR(255),
            OAUTH_VERSION LVARCHAR(128),
            CALLBACK_URL LVARCHAR(1024),
            GRANT_TYPES LVARCHAR (1024),
            PRIMARY KEY (CONSUMER_KEY)
);

CREATE TABLE IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN LVARCHAR(255),
            REQUEST_TOKEN_SECRET LVARCHAR(512),
            CONSUMER_KEY LVARCHAR(255),
            CALLBACK_URL LVARCHAR(1024),
            SCOPE LVARCHAR(2048),
            AUTHORIZED LVARCHAR(128),
            OAUTH_VERIFIER LVARCHAR(512),
            AUTHZ_USER LVARCHAR(512),
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
);


CREATE TABLE IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN LVARCHAR(255),
            ACCESS_TOKEN_SECRET LVARCHAR(512),
            CONSUMER_KEY LVARCHAR(255),
            SCOPE LVARCHAR(2048),
            AUTHZ_USER LVARCHAR(512),
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
);

CREATE TABLE IDN_OAUTH2_AUTHORIZATION_CODE (
            AUTHORIZATION_CODE LVARCHAR(255),
            CONSUMER_KEY LVARCHAR(255),
	        CALLBACK_URL LVARCHAR(1024),
            SCOPE LVARCHAR(2048),
            AUTHZ_USER LVARCHAR(512),
	        TIME_CREATED DATETIME YEAR TO SECOND,
	        VALIDITY_PERIOD BIGINT,
            PRIMARY KEY (AUTHORIZATION_CODE),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
);

CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN (
			ACCESS_TOKEN LVARCHAR(255),
			REFRESH_TOKEN LVARCHAR(255),
			CONSUMER_KEY LVARCHAR(255),
			AUTHZ_USER LVARCHAR(100),
			USER_TYPE LVARCHAR (25),
			TIME_CREATED DATETIME YEAR TO SECOND,
			VALIDITY_PERIOD BIGINT,
			TOKEN_SCOPE LVARCHAR(2048),
			TOKEN_STATE LVARCHAR(25) DEFAULT 'ACTIVE',
			TOKEN_STATE_ID LVARCHAR (255) DEFAULT 'NONE',
			PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE,
            UNIQUE (CONSUMER_KEY,AUTHZ_USER,USER_TYPE,TOKEN_SCOPE,TOKEN_STATE,TOKEN_STATE_ID) CONSTRAINT CON_APP_KEY
);

CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY, AUTHZ_USER, TOKEN_STATE, USER_TYPE);

CREATE TABLE IDN_OAUTH2_SCOPE (
            SCOPE_ID SERIAL UNIQUE,
            SCOPE_KEY LVARCHAR(100) NOT NULL,
            NAME LVARCHAR(255) NULL,
            DESCRIPTION LVARCHAR(512) NULL,
            TENANT_ID INTEGER NOT NULL,
            ROLES LVARCHAR (500) NULL,
            PRIMARY KEY (SCOPE_ID)
);

CREATE TABLE IDN_OAUTH2_RESOURCE_SCOPE (
            RESOURCE_PATH LVARCHAR(255) NOT NULL,
            SCOPE_ID INTEGER NOT NULL,
            PRIMARY KEY (RESOURCE_PATH),
            FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE
);

CREATE TABLE IDN_SCIM_GROUP (
			ID SERIAL UNIQUE,
			TENANT_ID INTEGER NOT NULL,
			ROLE_NAME LVARCHAR(255) NOT NULL,
            ATTR_NAME LVARCHAR(1024) NOT NULL,
			ATTR_VALUE LVARCHAR(1024)
);

CREATE TABLE IDN_SCIM_PROVIDER (
            CONSUMER_ID LVARCHAR(255) NOT NULL,
            PROVIDER_ID LVARCHAR(255) NOT NULL,
            USER_NAME LVARCHAR(255) NOT NULL,
            USER_PASSWORD LVARCHAR(255) NOT NULL,
            USER_URL LVARCHAR(1024) NOT NULL,
			GROUP_URL LVARCHAR(1024),
			BULK_URL LVARCHAR(1024),
            PRIMARY KEY (CONSUMER_ID,PROVIDER_ID)
);

CREATE TABLE IDN_OPENID_REMEMBER_ME (
            USER_NAME LVARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT 0,
            COOKIE_VALUE LVARCHAR(1024),
            CREATED_TIME DATETIME YEAR TO SECOND,
            PRIMARY KEY (USER_NAME, TENANT_ID)
);

CREATE TABLE IDN_OPENID_USER_RPS (
			USER_NAME LVARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0,
			RP_URL LVARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS LVARCHAR(128) DEFAULT 'f',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME LVARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
);

CREATE TABLE IDN_OPENID_ASSOCIATIONS (
			HANDLE LVARCHAR(255) NOT NULL,
			ASSOC_TYPE LVARCHAR(255) NOT NULL,
			EXPIRE_IN DATETIME YEAR TO SECOND NOT NULL,
			MAC_KEY LVARCHAR(255) NOT NULL,
			ASSOC_STORE LVARCHAR(128) DEFAULT 'SHARED',
			PRIMARY KEY (HANDLE)
);

CREATE TABLE IDN_STS_STORE (
             ID SERIAL UNIQUE,
             TOKEN_ID LVARCHAR(255) NOT NULL,
             TOKEN_CONTENT BLOB(1024) NOT NULL,
             CREATE_DATE DATETIME YEAR TO SECOND NOT NULL,
             EXPIRE_DATE DATETIME YEAR TO SECOND NOT NULL,
             STATE INTEGER DEFAULT 0
);

CREATE TABLE IDN_IDENTITY_USER_DATA (
             TENANT_ID INTEGER DEFAULT -1234,
             USER_NAME LVARCHAR(255) NOT NULL,
             DATA_KEY LVARCHAR(255) NOT NULL,
             DATA_VALUE LVARCHAR(255),
             PRIMARY KEY (TENANT_ID, USERR_NAME, DATA_KEY)
);

CREATE TABLE IDN_IDENTITY_META_DATA (
            USER_NAME LVARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
            METADATA_TYPE LVARCHAR(255) NOT NULL,
            METADATA LVARCHAR(255) NOT NULL,
            VALID LVARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)
);

CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (
            SESSION_ID LVARCHAR(255) NOT NULL,
            USER_NAME LVARCHAR(255) NOT NULL,
            CREATED_TIME LVARCHAR(255) NOT NULL,
            LAST_MODIFIED_TIME LVARCHAR(255) NOT NULL,
            PRIMARY KEY (SESSION_ID)
);
CREATE TABLE IF NOT EXISTS IDN_ASSOCIATED_ID (
            ID INTEGER SERIAL UNIQUE,
	    IDP_USER_ID VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
	    IDP_ID INTEGER NOT NULL,
            DOMAIN_ID INTEGER,
 	    USER_NAME VARCHAR(255) NOT NULL,
	    PRIMARY KEY (ID),
            UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
            FOREIGN KEY (DOMAIN_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID) ON DELETE CASCADE,
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
);
CREATE TABLE IDN_AUTH_SESSION_STORE (
            SESSION_ID LVARCHAR (100) DEFAULT NULL,
            SESSION_TYPE LVARCHAR(100) DEFAULT NULL,
            SESSION_OBJECT BLOB,
            TIME_CREATED TIMESTAMP,
            PRIMARY KEY (SESSION_ID, SESSION_TYPE)
);
