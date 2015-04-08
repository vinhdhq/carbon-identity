/**
 *  Copyright (c) 2014, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package org.wso2.carbon.identity.oauth.listener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.context.PrivilegedCarbonContext;
import org.wso2.carbon.identity.oauth.OAuthUtil;
import org.wso2.carbon.identity.oauth2.IdentityOAuth2Exception;
import org.wso2.carbon.identity.oauth2.dao.TokenMgtDAO;
import org.wso2.carbon.identity.oauth2.model.AccessTokenDO;
import org.wso2.carbon.identity.oauth2.util.OAuth2Util;
import org.wso2.carbon.user.core.common.AbstractUserOperationEventListener;

import java.util.Set;

/**
 * This is an implementation of UserOperationEventListener. This defines
 * additional operations
 * for some of the core user management operations
 */
public class IdentityOathEventListener extends AbstractUserOperationEventListener {
    private static final Log log = LogFactory.getLog(IdentityOathEventListener.class);

    /**
     * Bundle execution order id.
     */
    @Override
    public int getExecutionOrderId() {
        return 1501;
    }

    /**
     * Deleting user from the identity database prerequisites.
     */
    @Override
    public boolean doPreDeleteUser(java.lang.String username,
                                   org.wso2.carbon.user.core.UserStoreManager userStoreManager)
            throws org.wso2.carbon.user.core.UserStoreException {

        TokenMgtDAO tokenMgtDAO = new TokenMgtDAO();

        String tenantDomain = PrivilegedCarbonContext.getThreadLocalCarbonContext().getTenantDomain();
        username = (username + "@" + tenantDomain).toLowerCase();

        String userStoreDomain = null;
        if (OAuth2Util.checkAccessTokenPartitioningEnabled() && OAuth2Util.checkUserNameAssertionEnabled()) {
            try {
                userStoreDomain = OAuth2Util.getUserStoreDomainFromUserId(username);
            } catch (IdentityOAuth2Exception e) {
                log.error("Error occurred while getting user store domain for User ID : " + username, e);
                return true;
            }
        }

        Set<String> clientIds = null;
        try {
            // get all the distinct client Ids authorized by this user
            clientIds = tokenMgtDAO.getAllTimeAuthorizedClientIds(username);
        } catch (IdentityOAuth2Exception e) {
            log.error("Error occurred while retrieving apps authorized by User ID : " + username, e);
            return true;
        }
        for (String clientId : clientIds) {
            Set<AccessTokenDO> accessTokenDOs = null;
            try {
                // retrieve all ACTIVE or EXPIRED access tokens for particular client authorized by this user
                accessTokenDOs = tokenMgtDAO.retrieveAccessTokens(clientId, username, userStoreDomain, true);
            } catch (IdentityOAuth2Exception e) {
                String errorMsg = "Error occurred while retrieving access tokens issued for " +
                        "Client ID : " + clientId + ", User ID : " + username;
                log.error(errorMsg, e);
                return true;
            }
            for (AccessTokenDO accessTokenDO : accessTokenDOs) {
                //Clear cache
                OAuthUtil.clearOAuthCache(accessTokenDO.getConsumerKey(), accessTokenDO.getAuthzUser(),
                        OAuth2Util.buildScopeString(accessTokenDO.getScope()));
                OAuthUtil.clearOAuthCache(accessTokenDO.getConsumerKey(), accessTokenDO.getAuthzUser());
                OAuthUtil.clearOAuthCache(accessTokenDO.getAccessToken());
                AccessTokenDO scopedToken = null;
                try {
                    // retrieve latest access token for particular client, user and scope combination if its ACTIVE or EXPIRED
                    scopedToken = tokenMgtDAO.retrieveLatestAccessToken(
                            clientId, username, userStoreDomain,
                            OAuth2Util.buildScopeString(accessTokenDO.getScope()), true);
                } catch (IdentityOAuth2Exception e) {
                    String errorMsg = "Error occurred while retrieving latest " +
                            "access token issued for Client ID : " +
                            clientId + ", User ID : " + username + " and Scope : " +
                            OAuth2Util.buildScopeString(accessTokenDO.getScope());
                    log.error(errorMsg, e);
                    return true;
                }
                if (scopedToken != null) {
                    try {
                        //Revoking token from database
                        tokenMgtDAO.revokeToken(scopedToken.getAccessToken());
                    } catch (IdentityOAuth2Exception e) {
                        String errorMsg = "Error occurred while revoking " +
                                "Access Token : " + scopedToken.getAccessToken();
                        log.error(errorMsg, e);
                        return true;
                    }
                }
            }
        }
        return true;
    }
}
