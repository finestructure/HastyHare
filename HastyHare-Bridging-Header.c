//
//  HastyHare-Bridging-Header.c
//  HastyHare
//
//  Created by Sven A. Schmidt on 28/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

#include "HastyHare-Bridging-Header.h"

amqp_rpc_reply_t amqp_login_with_credentials(amqp_connection_state_t state, char const *vhost,
                                             int channel_max, int frame_max, int heartbeat,
                                             amqp_sasl_method_enum sasl_method, const char * user, const char * password) {
    return amqp_login(state, vhost, channel_max, frame_max, heartbeat, sasl_method, user, password);
}
