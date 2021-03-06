#!/bin/bash

function usage() {
  printf "Usage: $0 {install|start|dashboard|ip|stop|delete|help}\n\n"
  printf "Options:\n"
  printf "  dashboard      show minikube dashboard\n"
  printf "  delete         remove the minikube machine\n"
  printf "  help           show help\n"
  printf "  install        install & start minikube with dev-tools Jenkins & Gitlab\n"
  printf "  ip             get minikube ip\n"
  printf "  start          start minikube\n"
  printf "  stop           stop minikube\n\n"
  exit 1
}

function apply_descriptor() {
    for var in "$@"
    do
        printf "\n---- Applying descriptor [${var}] ----\n"
        IP=$(minikube ip)
        cat ${var} | sed s/192.168.99.100/${IP}/ | kubectl apply -f -
    done
}

function run() {
  ACTION="$@"
    case "${ACTION}" in
        install)
            DIR=$(pwd)
            cd ${DIR}/kubernetes && ./start-minikube.sh
            cd ${DIR}/dev-tools && ./deploy-dev-tools.sh
            ;;
        start)
            minikube start
            echo "re-applying traefik descriptor in case minikube ip has changed..."
            apply_descriptor kubernetes/traefik.yml
            ;;
        dashboard)
            minikube dashboard
            ;;
        ip)
            minikube ip
            ;;
        stop)
            minikube stop
            ;;
        delete)
            minikube delete
            ;;
        help)
            usage
            ;;
        *)
            echo "Unknown option: [${ACTION}]"
            usage
            ;;
    esac
}

run $@
