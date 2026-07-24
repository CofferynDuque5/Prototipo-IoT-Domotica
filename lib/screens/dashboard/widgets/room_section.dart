import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/device_controller.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/room_model.dart';
import '../../../widgets/device_card.dart';

/// Sección del dashboard que agrupa las tarjetas de dispositivos de una
/// habitación en una cuadrícula responsiva.
class RoomSection extends StatelessWidget {
  final RoomModel room;

  const RoomSection({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = context.watch<DeviceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.meeting_room_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                room.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${room.activos}/${room.total}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Cuadrícula adaptable: 2 columnas en móvil, más en pantallas anchas.
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth ~/ 200;
            final int crossAxisCount = columns.clamp(2, 4);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: room.dispositivos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final device = room.dispositivos[index];
                return Hero(
                  tag: 'device-${device.id}',
                  child: DeviceCard(
                    device: device,
                    pending: controller.isPending(device.id),
                    onToggle: (_) => controller.toggle(device),
                    onTap: () => context.pushNamed(
                      RouteNames.deviceDetail,
                      pathParameters: {'id': device.id},
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
