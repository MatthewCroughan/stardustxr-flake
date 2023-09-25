set -eu
trap "pkill monado; pkill stardust-xr; pkill azimuth; pkill eclipse; pkill flatland; pkill sway" EXIT
XRT_CALIBRATE_GYRO=1 XRT_COMPOSITOR_SCALE_PERCENTAGE=100 XRT_MESH_SIZE=48 XRT_COMPOSITOR_FORCE_XCB=1 XRT_COMPOSITOR_XCB_FULLSCREEN=1 monado-service </dev/ttyS0 &
sleep 3
exec stardust-xr-server &
sleep 3
exec flatland &
sleep 0.1;
#WAYLAND_DISPLAY=wayland-0 wlxmirror --desktop wayland-1 --mirror wayland-2 --output eDP-1
echo "Now mirror your display onto flatland"
echo "an example might look like this"
echo ""
echo "WAYLAND_DISPLAY=wayland-2 wlxmirror --desktop wayland-1 --mirror wayland-2 --output eDP-1"
wait
