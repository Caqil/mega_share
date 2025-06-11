import os
import shutil

def create_directory(path):
    """Create a directory if it doesn't exist"""
    os.makedirs(path, exist_ok=True)

def create_file(path):
    """Create an empty file if it doesn't exist"""
    if not os.path.exists(path):
        with open(path, 'w') as f:
            f.write('')  # Create empty file

def create_project_structure():
    # Root directories
    root_dirs = ['lib', 'assets']
    for dir_name in root_dirs:
        create_directory(dir_name)

    # lib/ directory structure
    lib_structure = {
        'lib': [
            'main.dart',
            {'app': [
                'app.dart',
                {'router': ['app_router.dart', 'route_names.dart']},
                {'theme': ['app_theme.dart', 'color_schemes.dart', 'text_styles.dart']}
            ]},
            {'core': [
                {'constants': ['app_constants.dart', 'file_constants.dart', 'connection_constants.dart']},
                {'errors': ['exceptions.dart', 'failures.dart', 'error_handler.dart']},
                {'network': ['network_info.dart', 'connection_checker.dart']},
                {'utils': ['file_utils.dart', 'permission_utils.dart', 'device_info_utils.dart', 
                         'date_time_utils.dart', 'size_utils.dart']},
                {'extensions': ['string_extensions.dart', 'file_extensions.dart', 'context_extensions.dart']},
                {'services': ['storage_service.dart', 'permission_service.dart', 
                            'notification_service.dart', 'logger_service.dart']}
            ]},
            {'features': [
                {'device_discovery': [
                    {'data': [
                        {'datasources': ['nearby_devices_datasource.dart', 'nearby_devices_datasource_impl.dart']},
                        {'models': ['device_model.dart', 'discovery_result_model.dart']},
                        {'repositories': ['device_discovery_repository_impl.dart']}
                    ]},
                    {'domain': [
                        {'entities': ['device_entity.dart', 'discovery_result_entity.dart']},
                        {'repositories': ['device_discovery_repository.dart']},
                        {'usecases': ['start_discovery_usecase.dart', 'stop_discovery_usecase.dart',
                                    'start_advertising_usecase.dart', 'stop_advertising_usecase.dart']}
                    ]},
                    {'presentation': [
                        {'bloc': ['device_discovery_bloc.dart', 'device_discovery_event.dart', 
                                 'device_discovery_state.dart']},
                        {'pages': ['discovery_page.dart', 'device_list_page.dart']},
                        {'widgets': ['device_card.dart', 'discovery_fab.dart', 
                                   'discovery_status_indicator.dart']}
                    ]}
                ]},
                {'file_management': [
                    {'data': [
                        {'datasources': ['file_system_datasource.dart', 'file_system_datasource_impl.dart']},
                        {'models': ['file_model.dart', 'folder_model.dart', 'storage_info_model.dart']},
                        {'repositories': ['file_management_repository_impl.dart']}
                    ]},
                    {'domain': [
                        {'entities': ['file_entity.dart', 'folder_entity.dart', 'storage_info_entity.dart']},
                        {'repositories': ['file_management_repository.dart']},
                        {'usecases': ['get_files_usecase.dart', 'get_folders_usecase.dart',
                                    'create_folder_usecase.dart', 'delete_file_usecase.dart',
                                    'get_storage_info_usecase.dart']}
                    ]},
                    {'presentation': [
                        {'bloc': ['file_management_bloc.dart', 'file_management_event.dart', 
                                 'file_management_state.dart']},
                        {'pages': ['file_explorer_page.dart', 'file_selector_page.dart', 
                                  'media_gallery_page.dart']},
                        {'widgets': ['file_item.dart', 'folder_item.dart', 'file_type_filter.dart',
                                   'storage_indicator.dart', 'file_preview_modal.dart']}
                    ]}
                ]},
                {'file_transfer': [
                    {'data': [
                        {'datasources': ['transfer_datasource.dart', 'transfer_datasource_impl.dart']},
                        {'models': ['transfer_model.dart', 'transfer_progress_model.dart', 
                                  'transfer_session_model.dart']},
                        {'repositories': ['file_transfer_repository_impl.dart']}
                    ]},
                    {'domain': [
                        {'entities': ['transfer_entity.dart', 'transfer_progress_entity.dart', 
                                    'transfer_session_entity.dart']},
                        {'repositories': ['file_transfer_repository.dart']},
                        {'usecases': ['send_files_usecase.dart', 'receive_files_usecase.dart',
                                    'pause_transfer_usecase.dart', 'resume_transfer_usecase.dart',
                                    'cancel_transfer_usecase.dart', 'get_transfer_history_usecase.dart']}
                    ]},
                    {'presentation': [
                        {'bloc': ['file_transfer_bloc.dart', 'file_transfer_event.dart', 
                                 'file_transfer_state.dart']},
                        {'pages': ['transfer_page.dart', 'send_page.dart', 'receive_page.dart',
                                  'transfer_history_page.dart']},
                        {'widgets': ['transfer_progress_card.dart', 'transfer_speed_indicator.dart',
                                   'transfer_controls.dart', 'file_transfer_item.dart', 
                                   'qr_code_scanner.dart']}
                    ]}
                ]},
                {'connection': [
                    {'data': [
                        {'datasources': ['nearby_connection_datasource.dart', 
                                       'nearby_connection_datasource_impl.dart']},
                        {'models': ['connection_model.dart', 'connection_info_model.dart', 
                                  'endpoint_model.dart']},
                        {'repositories': ['connection_repository_impl.dart']}
                    ]},
                    {'domain': [
                        {'entities': ['connection_entity.dart', 'connection_info_entity.dart', 
                                    'endpoint_entity.dart']},
                        {'repositories': ['connection_repository.dart']},
                        {'usecases': ['connect_to_device_usecase.dart', 'disconnect_from_device_usecase.dart',
                                    'accept_connection_usecase.dart', 'reject_connection_usecase.dart',
                                    'get_connection_info_usecase.dart']}
                    ]},
                    {'presentation': [
                        {'bloc': ['connection_bloc.dart', 'connection_event.dart', 
                                 'connection_state.dart']},
                        {'pages': ['connection_page.dart', 'connection_request_page.dart']},
                        {'widgets': ['connection_status_card.dart', 'connection_request_dialog.dart',
                                   'qr_code_generator.dart', 'wifi_hotspot_toggle.dart']}
                    ]}
                ]},
                {'settings': [
                    {'data': [
                        {'datasources': ['settings_datasource.dart', 'settings_datasource_impl.dart']},
                        {'models': ['settings_model.dart', 'theme_model.dart']},
                        {'repositories': ['settings_repository_impl.dart']}
                    ]},
                    {'domain': [
                        {'entities': ['settings_entity.dart', 'theme_entity.dart']},
                        {'repositories': ['settings_repository.dart']},
                        {'usecases': ['get_settings_usecase.dart', 'update_settings_usecase.dart',
                                    'reset_settings_usecase.dart', 'export_settings_usecase.dart']}
                    ]},
                    {'presentation': [
                        {'bloc': ['settings_bloc.dart', 'settings_event.dart', 'settings_state.dart']},
                        {'pages': ['settings_page.dart', 'theme_settings_page.dart',
                                  'transfer_settings_page.dart', 'about_page.dart']},
                        {'widgets': ['settings_tile.dart', 'theme_selector.dart', 
                                   'toggle_setting.dart', 'slider_setting.dart']}
                    ]}
                ]},
                {'home': [
                    {'presentation': [
                        {'bloc': ['home_bloc.dart', 'home_event.dart', 'home_state.dart']},
                        {'pages': ['home_page.dart', 'main_navigation_page.dart', 'onboarding_page.dart']},
                        {'widgets': ['home_app_bar.dart', 'quick_action_grid.dart',
                                   'recent_transfers.dart', 'device_status_card.dart',
                                   'bottom_navigation.dart']}
                    ]}
                ]}
            ]},
            {'shared': [
                {'widgets': [
                    {'common': ['custom_app_bar.dart', 'custom_button.dart', 'custom_text_field.dart',
                              'loading_widget.dart', 'error_widget.dart', 'empty_state_widget.dart',
                              'confirmation_dialog.dart', 'custom_bottom_sheet.dart']},
                    {'file': ['file_icon.dart', 'file_size_text.dart', 'file_thumbnail.dart',
                            'file_progress_indicator.dart']},
                    {'animations': ['fade_in_animation.dart', 'slide_animation.dart',
                                  'scale_animation.dart', 'transfer_animation.dart']}
                ]},
                {'models': ['base_model.dart', 'api_response.dart', 'pagination_model.dart']},
                {'bloc': ['base_bloc.dart', 'base_event.dart', 'base_state.dart']}
            ]},
            {'injection': ['injection.dart', 'injection.config.dart', 'register_modules.dart']}
        ]
    }

    # assets/ directory structure
    assets_structure = {
        'assets': [
            {'images': [
                'app_logo.png',
                {'file_icons': ['pdf_icon.png', 'doc_icon.png', 'image_icon.png',
                              'video_icon.png', 'audio_icon.png', 'zip_icon.png',
                              'unknown_icon.png']},
                {'illustrations': ['empty_files.svg', 'no_devices.svg',
                                'transfer_complete.svg', 'connection_failed.svg']},
                {'animations': ['loading.json', 'success.json', 'transfer.json']}
            ]},
            {'icons': [
                'app_icon.png',
                {'adaptive_icons': ['foreground.png', 'background.png']}
            ]},
            {'fonts': [
                {'Roboto': ['Roboto-Regular.ttf', 'Roboto-Medium.ttf',
                          'Roboto-Bold.ttf', 'Roboto-Light.ttf']},
                'custom_icons.ttf'
            ]}
        ]
    }

    def create_structure(base_path, structure):
        """Recursively create directory structure and files"""
        for key, value in structure.items():
            if isinstance(value, list):
                # Create directory
                dir_path = os.path.join(base_path, key)
                create_directory(dir_path)
                
                # Create files or subdirectories
                for item in value:
                    if isinstance(item, str):
                        create_file(os.path.join(dir_path, item))
                    elif isinstance(item, dict):
                        create_structure(dir_path, item)
            elif isinstance(value, dict):
                # Create directory and process its contents
                dir_path = os.path.join(base_path, key)
                create_directory(dir_path)
                create_structure(dir_path, value)

    # Create the structures
    create_structure('.', lib_structure)
    create_structure('.', assets_structure)

    print("Project structure created successfully!")

if __name__ == "__main__":
    create_project_structure()