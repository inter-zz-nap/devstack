_nova()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="absolute-limits actions add-fixed-ip add-floating-ip aggregate-add-host
          aggregate-create aggregate-delete aggregate-details aggregate-list
          aggregate-remove-host aggregate-set-metadata aggregate-update boot credentials
          delete describe-resource diagnostics dns-create dns-create-private-domain
          dns-create-public-domain dns-delete dns-delete-domain dns-domains dns-list
          endpoints flavor-create flavor-delete flavor-list floating-ip-create
          floating-ip-delete floating-ip-list floating-ip-pool-list get-vnc-console
          image-create image-delete image-list image-meta image-show keypair-add
          keypair-delete keypair-list list live-migration meta migrate pause rate-limits
          reboot rebuild remove-fixed-ip remove-floating-ip rename rescue resize
          resize-confirm resize-revert resume root-password secgroup-add-group-rule
          secgroup-add-rule secgroup-create secgroup-delete secgroup-delete-group-rule
          secgroup-delete-rule secgroup-list secgroup-list-rules show ssh suspend unpause
          unrescue usage-list volume-attach volume-create volume-delete volume-detach
          volume-list volume-show volume-snapshot-create volume-snapshot-delete
          volume-snapshot-list volume-snapshot-show x509-create-cert x509-get-root-cert
          bash-completion help
          --debug --endpoint_name --password --projectid --region_name --url
          --username --version"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _nova nova

   