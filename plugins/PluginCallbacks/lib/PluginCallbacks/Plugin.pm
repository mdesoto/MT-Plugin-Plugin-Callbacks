# Copyright 2010 Michael De Soto. This program is distributed under the 
# terms of the GNU General Public License.

package PluginCallbacks::Plugin;

use strict;
use warnings;

sub init_app {
    *MT::Plugin::save_config = \&save_config;
}

sub save_config {
    my $plugin = shift;
    my ($param, $scope) = @_;
    my $pdata = $plugin->get_config_obj($scope);
    $scope =~ s/:.*//;
    my @vars = $plugin->config_vars($scope);
    my $data = $pdata->data() || {};
    foreach (@vars) {
        $data->{$_} = exists $param->{$_} ? $param->{$_} : undef;
    }
    $pdata->data($data);
    MT->request('plugin_config.'.$plugin->id, undef);
    
    MT->run_callbacks('pc_pre_save_config', $param, $scope);
    
    $pdata->save() or die $pdata->errstr;
    
    MT->run_callbacks('pc_post_save_config', $param, $scope);
}

1;